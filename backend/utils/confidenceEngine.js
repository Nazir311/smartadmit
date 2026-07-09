const Department = require('../models/Department');

const WEIGHTS = {
  academicAlignment: 0.30,
  interestAlignment: 0.25,
  careerAlignment: 0.25,
  practicalFit: 0.20
};

const calcAcademicAlignment = (dept, profile) => {
  const effectiveGpa = Math.min(profile.sscGpa || 0, profile.hscGpa || 0);
  if (effectiveGpa === 0) return 50;
  const gap = effectiveGpa - dept.minGPA;
  if (gap >= 0.5) return 95;
  if (gap >= 0.25) return 82;
  if (gap >= 0) return 68;
  return 0;
};

const calcInterestAlignment = (dept, profile) => {
  const interests = [...(profile.interests || []), ...(profile.favoriteSubjects || []), ...(profile.skills || [])];
  if (interests.length === 0) return 50;
  const deptKeywords = dept.keywordMatch || [];
  let matches = 0;
  for (const interest of interests) {
    const il = interest.toLowerCase();
    if (deptKeywords.some(k => k.includes(il) || il.includes(k))) matches++;
    if (dept.tags.some(t => t.includes(il) || il.includes(t))) matches++;
  }
  const score = Math.min(100, (matches / interests.length) * 100 + (matches > 0 ? 20 : 0));
  return Math.round(score);
};

const calcCareerAlignment = (dept, profile) => {
  const goals = profile.careerGoals || [];
  if (goals.length === 0) return 50;
  const careerKeywords = dept.careerMatch || [];
  let matches = 0;
  for (const goal of goals) {
    const gl = goal.toLowerCase();
    if (careerKeywords.some(k => k.includes(gl) || gl.includes(k))) matches++;
    if (dept.careers.some(c => c.toLowerCase().includes(gl) || gl.includes(c.toLowerCase().split(' ')[0]))) matches++;
  }
  const score = Math.min(100, (matches / goals.length) * 100 + (matches > 0 ? 15 : 0));
  return Math.round(score);
};

const calcPracticalFit = (dept, profile) => {
  let score = 70;
  if (profile.financialConstraint === 'low' && dept.tuitionPerSemester > 9000) score -= 20;
  if (profile.financialConstraint === 'low' && dept.tuitionPerSemester <= 8000) score += 10;
  if (profile.scholarshipInterest === true) score += 5;
  if (profile.group === 'Science' && dept.requiredSubjects.some(s => s.toLowerCase().includes('physics'))) score += 15;
  if (profile.group === 'Business' && dept.faculty.toLowerCase().includes('business')) score += 20;
  if (profile.group === 'Humanities' && dept.faculty.toLowerCase().includes('humanities')) score += 20;
  if (profile.group === 'Business' && dept.requiredSubjects.some(s => s.toLowerCase().includes('physics'))) score -= 30;
  if (profile.group === 'Humanities' && dept.requiredSubjects.some(s => s.toLowerCase().includes('physics'))) score -= 30;
  return Math.max(0, Math.min(100, score));
};

const generateReasoning = (dept, scores, profile) => {
  const reasons = [];
  if (scores.academicAlignment >= 90) reasons.push(`Excellent GPA fit — your GPA of ${Math.min(profile.sscGpa, profile.hscGpa)} comfortably meets the ${dept.minGPA} requirement`);
  else if (scores.academicAlignment >= 70) reasons.push(`Good GPA alignment with the ${dept.minGPA} minimum requirement`);
  else if (scores.academicAlignment > 0) reasons.push(`GPA is borderline — focus on the admission test score`);

  if (scores.interestAlignment >= 80) reasons.push(`Strong interest match with your subjects/skills in ${dept.tags.slice(0, 2).join(', ')}`);
  else if (scores.interestAlignment >= 60) reasons.push(`Moderate interest alignment with ${dept.name}`);

  if (scores.careerAlignment >= 80) reasons.push(`Your career goals closely align with ${dept.careers.slice(0, 2).join(' and ')}`);
  else if (scores.careerAlignment >= 60) reasons.push(`Career path supports goals in ${dept.industrySectors ? dept.industrySectors[0] : 'this industry'}`);

  if (scores.practicalFit >= 85) reasons.push(`Excellent practical fit — group background and financial situation align well`);
  if (profile.scholarshipInterest && scores.academicAlignment >= 80) reasons.push(`High scholarship eligibility based on your GPA`);

  if (reasons.length === 0) reasons.push(`${dept.name} is a viable option based on your profile`);
  return reasons;
};

const scoreAllDepartments = async (profile) => {
  const effectiveGpa = Math.min(profile.sscGpa || 0, profile.hscGpa || 0);
  const eligible = await Department.find({ minGPA: { $lte: effectiveGpa > 0 ? effectiveGpa : 5 }, isActive: true });

  const scored = eligible.map(dept => {
    const academicAlignment = calcAcademicAlignment(dept, profile);
    const interestAlignment = calcInterestAlignment(dept, profile);
    const careerAlignment = calcCareerAlignment(dept, profile);
    const practicalFit = calcPracticalFit(dept, profile);

    const confidenceScore = Math.round(
      academicAlignment * WEIGHTS.academicAlignment +
      interestAlignment * WEIGHTS.interestAlignment +
      careerAlignment * WEIGHTS.careerAlignment +
      practicalFit * WEIGHTS.practicalFit
    );

    const scores = { academicAlignment, interestAlignment, careerAlignment, practicalFit };
    return {
      code: dept.code,
      name: dept.name,
      faculty: dept.faculty,
      confidenceScore,
      academicAlignment,
      interestAlignment,
      careerAlignment,
      practicalFit,
      reasoning: generateReasoning(dept, scores, profile),
      careerRoadmap: dept.roadmap || { year1: [], year2: [], year3: [], year4: [] },
      jobRoles: dept.jobRoles || [],
      industryPaths: dept.industrySectors || [],
      tuitionPerSemester: dept.tuitionPerSemester,
      scholarshipChance: academicAlignment >= 90 ? '50-100% waiver possible' : academicAlignment >= 70 ? '25-50% waiver possible' : 'Limited — check special quotas'
    };
  });

  return scored.sort((a, b) => b.confidenceScore - a.confidenceScore).slice(0, 3);
};

module.exports = { scoreAllDepartments };
