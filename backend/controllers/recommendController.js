const Department = require('../models/Department');

const departmentReasons = {
  CSE: 'Ideal for tech enthusiasts. Bangladesh\'s IT sector is booming with high salary packages and global remote work opportunities.',
  EEE: 'Strong demand in power sector, telecom, and manufacturing. Core engineering discipline with solid job market.',
  ECE: 'Bridges electronics and communication. Growing IoT, automation, and telecom industries need ECE graduates.',
  ME: 'Foundation of all industries. Automotive, manufacturing, and energy sectors always need mechanical engineers.',
  CE: 'Infrastructure boom in Bangladesh makes civil engineers highly sought after. Government and private sector both hire heavily.',
  TE: 'Bangladesh is #2 globally in garment exports. Textile engineers command excellent salaries in this export-driven sector.',
  BBA: 'Versatile business degree. Opens paths to entrepreneurship, banking, marketing, corporate management, and NGO sector.',
  ARCH: 'Rapidly urbanizing Bangladesh needs architects. Creative profession with both artistic and technical dimensions.',
  PHARM: 'Pharmaceutical sector growing at 15% annually in Bangladesh. Strong career stability in hospitals and industry.',
  ENG: 'Teaching, journalism, translation, content creation, and diplomacy. Open to all academic backgrounds.'
};

const getRecommendations = async (req, res) => {
  const { gpa, interests = [], sscGpa, hscGpa } = req.body;

  let effectiveGPA;
  if (sscGpa && hscGpa) {
    effectiveGPA = Math.min(parseFloat(sscGpa), parseFloat(hscGpa));
  } else {
    effectiveGPA = parseFloat(gpa);
  }

  if (isNaN(effectiveGPA) || effectiveGPA < 0 || effectiveGPA > 5) {
    return res.status(400).json({ success: false, message: 'Please provide a valid GPA between 0.0 and 5.0.' });
  }

  const eligible = await Department.find({ minGPA: { $lte: effectiveGPA }, isActive: true }).sort({ minGPA: -1 });

  const tier = effectiveGPA >= 4.5 ? 'Excellent' : effectiveGPA >= 4.0 ? 'Good' : effectiveGPA >= 3.5 ? 'Average' : 'Below Average';

  let interestMatched = [];
  if (interests.length > 0) {
    interestMatched = eligible.filter(d => d.tags.some(t => interests.some(i => t.includes(i.toLowerCase()))));
  }

  const recommendations = eligible.slice(0, 8).map(dept => {
    const gap = effectiveGPA - dept.minGPA;
    const matchStrength = gap >= 0.5 ? 'Strong Match' : gap >= 0.25 ? 'Good Match' : 'Borderline';
    return {
      code: dept.code,
      name: dept.name,
      faculty: dept.faculty,
      minGPA: dept.minGPA,
      seats: dept.seats,
      tuitionPerSemester: dept.tuitionPerSemester,
      duration: dept.duration,
      careers: dept.careers,
      matchStrength,
      gpaGap: Math.round(gap * 100) / 100,
      reason: departmentReasons[dept.code] || `${dept.name} is a strong match for GPA ${effectiveGPA}.`,
      interestMatch: interestMatched.some(d => d.code === dept.code)
    };
  });

  return res.status(200).json({
    success: true,
    gpa: effectiveGPA,
    tier,
    totalEligible: eligible.length,
    recommendations,
    interestMatchCount: interestMatched.length
  });
};

module.exports = { getRecommendations };
