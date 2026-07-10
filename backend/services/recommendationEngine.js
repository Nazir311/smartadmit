const calculateRecommendation = (department, student) => {
    let score = 0;
    const reasons = [];
  
    // ==========================
// Academic Score (25)
// ==========================

const gpa =
((student.sscGpa || 0) +
 (student.hscGpa || 0)) / 2;

if (gpa >= 5) {
score += 25;
reasons.push("Outstanding academic performance");
} else if (gpa >= 4.8) {
score += 23;
reasons.push("Excellent academic performance");
} else if (gpa >= 4.5) {
score += 20;
reasons.push("Very good academic performance");
} else if (gpa >= 4) {
score += 16;
reasons.push("Good academic performance");
} else if (gpa >= 3.5) {
score += 12;
reasons.push("Average academic performance");
}

// ==========================
// Interest Match (20)
// ==========================

const interests = (student.interests || []).map(i =>
    i.toLowerCase()
  );
  
  const tags = (department.interestTags || []).map(t =>
    t.toLowerCase()
  );
  
  let matched = 0;
  
  for (const tag of tags) {
    if (interests.includes(tag)) {
      matched++;
    }
  }
  
  score += Math.min(matched * 5, 20);
  
  if (matched > 0) {
    reasons.push(`${matched} interest(s) matched`);
  }
// ==========================
// Career Goal Match (20)
// ==========================

const goal = (student.careerGoal || "").toLowerCase();

const careers = (department.careerPaths || []).map(e =>
  e.toLowerCase()
);

let careerMatched = false;

for (const career of careers) {

  if (
    career.includes(goal) ||
    goal.includes(career)
  ) {

    score += 20;

    careerMatched = true;

    reasons.push(
      "Career goal strongly matches this department"
    );

    break;
  }
}

if (
  !careerMatched &&
  goal.length > 0
) {

  score += 5;

  reasons.push(
    "Related career opportunities available"
  );

}

// ==========================
// Job Market Bonus
// ==========================

if (
    department.jobSectors &&
    department.jobSectors.length > 2
  ) {
  
    score += 5;
  
    reasons.push(
      "Multiple job sectors available"
    );
  
  }
  
  if (
    department.topCompanies &&
    department.topCompanies.length > 2
  ) {
  
    score += 5;
  
    reasons.push(
      "Strong hiring companies available"
    );
  
  }
// ==========================
// Tuition Affordability (10)
// ==========================

if (student.budget) {

    if (department.tuitionFee <= student.budget) {
  
      score += 10;
  
      reasons.push(
        "Fits within your budget"
      );
  
    }
  
    else if (
      department.tuitionFee <=
      student.budget + 100000
    ) {
  
      score += 5;
  
      reasons.push(
        "Slightly above your budget"
      );
  
    }
  
  }
  
    // ==========================
    // BD Demand (10 Marks)
    // ==========================
  
    switch ((department.bdDemand || "").toLowerCase()) {
      case "very high":
        score += 10;
        break;
  
      case "high":
        score += 8;
        break;
  
      case "medium":
        score += 5;
        break;
  
      default:
        score += 2;
    }
  
    // ==========================
    // Global Demand (5 Marks)
    // ==========================
  
    switch ((department.globalDemand || "").toLowerCase()) {
      case "very high":
        score += 5;
        break;
  
      case "high":
        score += 4;
        break;
  
      case "medium":
        score += 2;
        break;
    }
  
    // ==========================
    // Scholarship Bonus
    // ==========================
  
    if (
      student.needScholarship &&
      department.scholarship === "Yes"
    ) {
      score += 5;
      reasons.push("Scholarship available");
    }
  
    // ==========================
    // Internship Bonus
    // ==========================
  
    if (department.internship === "Yes") {
      score += 5;
      reasons.push("Internship available");
    }
  
    // ==========================
    // Confidence
    // ==========================
  
    let confidence = "Low";
  

if (score >= 90) {
  confidence = "Excellent";
} else if (score >= 80) {
  confidence = "Very High";
} else if (score >= 70) {
  confidence = "High";
} else if (score >= 60) {
  confidence = "Medium";
}
  
    return {
      score,
      confidence,
      reasons,
    };
  };
  
  const rankDepartments = (departments, student) => {
    const ranked = departments.map((dept) => {
      const result = calculateRecommendation(
        dept,
        student
      );
  
      return {

        ...dept.toObject(),
      
        score: result.score,
      
        confidence: result.confidence,
      
        reasons: result.reasons,
      
        summary: `${dept.department} offers strong opportunities in ${dept.jobSectors.join(", ")} with ${dept.bdDemand} demand in Bangladesh.`,
      
        careerSummary: dept.careerPaths.slice(0, 3).join(", "),
      
        salary: dept.entrySalary,
      
        companies: dept.topCompanies,
      
        demand: dept.bdDemand,
      
        pros: [
          `BD Demand: ${dept.bdDemand}`,
          `Global Demand: ${dept.globalDemand}`,
          `Scholarship: ${dept.scholarship}`,
          `Internship: ${dept.internship}`
        ],
      
        careerOutlook: `${dept.department} graduates can work as ${dept.careerPaths.slice(0,3).join(", ")}.`,
      
        growthIndex:
          dept.bdDemand === "Very High"
            ? "★★★★★"
            : dept.bdDemand === "High"
            ? "★★★★☆"
            : dept.bdDemand === "Medium"
            ? "★★★☆☆"
            : "★★☆☆☆"
      
      };
    });
  
    ranked.sort((a, b) => b.score - a.score);
  
    return ranked.slice(0, 3);
  };
  
  module.exports = {
    calculateRecommendation,
    rankDepartments,
  };