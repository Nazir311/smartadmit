const StudentProfile = require('../models/StudentProfile');
const Recommendation = require('../models/Recommendation');
const { scoreAllDepartments } = require('./confidenceEngine');

const STAGE_QUESTIONS = {
  greeting: null,
  gpa: `To give you the best department recommendation, I need a few details about you.\n\n**What is your SSC GPA?** (e.g. 4.50 or 5.00)`,
  hscGpa: `Got it! And what is your **HSC GPA**?`,
  group: `Which academic group were you in for HSC?\n\n• **Science** (Physics, Chemistry, Math/Biology)\n• **Business** (Accounting, Finance, Economics)\n• **Humanities** (Bangladesh Studies, Civics, etc.)`,
  subjects: `Great! Which subjects do you enjoy most or feel strongest in? (e.g. Math, Physics, Programming, English, Art, Biology — you can mention multiple)`,
  interests: `What are your main **interests or hobbies**? For example: coding, design, business, sports, writing, electronics, social work...`,
  career: `Almost there! What are your **career goals or dream job**? What kind of work do you see yourself doing in 5 years? (e.g. software developer, entrepreneur, doctor, engineer, teacher...)`,
  financial: `Last question: Do you have any **budget constraints** for tuition?\n\n• **Low budget** — scholarship is important\n• **Medium budget** — some flexibility\n• **High budget** — no constraint`,
  complete: null
};

const extractSSCGpa = (msg) => {
  const m = msg.match(/\b([0-4]\.\d{1,2}|5\.0{1,2}|[0-5])\b/);
  if (m) { const v = parseFloat(m[1]); if (v >= 0 && v <= 5) return v; }
  return null;
};

const extractGroup = (msg) => {
  const ml = msg.toLowerCase();
  if (/science|phy|chem|bio|math|sci/.test(ml)) return 'Science';
  if (/business|commerce|account|finance|eco/.test(ml)) return 'Business';
  if (/human|arts|civic|bangla|history/.test(ml)) return 'Humanities';
  return null;
};

const extractBudget = (msg) => {
  const ml = msg.toLowerCase();
  if (/low|tight|poor|limited|scholarship|waiver|no money|can't afford/.test(ml)) return 'low';
  if (/medium|moderate|some|middle|okay/.test(ml)) return 'medium';
  if (/high|no problem|afford|rich|no constraint|fine/.test(ml)) return 'high';
  return null;
};

const extractList = (msg) => {
  return msg.split(/[,، ،and\n]+/).map(s => s.trim()).filter(s => s.length > 1 && s.length < 40);
};

const buildParentSummaryEn = (top3, profile) => {

  if (!top3 || top3.length === 0) {
    return "No recommendation available.";
  }

  const top = top3[0];

  return `Dear Parent,

Based on your child's academic profile:

Recommended Department:
${top.department}

Department Code:
${top.code}

Faculty:
${top.faculty}

Duration:
${top.duration}

Tuition Fee:
BDT ${top.tuitionFee}

Starting Salary:
${top.salary}

Career Paths:
${(top.careerPaths || []).slice(0,5).join(", ")}

Top Companies:
${(top.companies || []).join(", ")}

Bangladesh Demand:
${top.demand}

Summary:
${top.summary}

Thank you.`;
};

const buildParentSummaryBn = (top3, profile) => {

  if (!top3 || top3.length === 0) {
    return "কোন সুপারিশ পাওয়া যায়নি।";
  }

  const top = top3[0];

  return `প্রিয় অভিভাবক,

প্রস্তাবিত বিভাগ:

${top.department}

কোড:
${top.code}

ফ্যাকাল্টি:
${top.faculty}

মেয়াদ:
${top.duration}

টিউশন ফি:
BDT ${top.tuitionFee}

শুরুর বেতন:
${top.salary}

ক্যারিয়ার:
${(top.careerPaths || []).slice(0,5).join(", ")}

প্রধান কোম্পানি:
${(top.companies || []).join(", ")}

বাংলাদেশে চাহিদা:
${top.demand}

${top.summary}`;
};

const processAgentMessage = async (message, sessionId) => {
  let profile = await StudentProfile.findOne({ sessionId });
  if (!profile) {
    profile = new StudentProfile({ sessionId, completionStage: 'greeting' });
  }

  const stage = profile.completionStage;

  if (stage === 'greeting') {
    profile.completionStage = 'gpa';
    await profile.save();
    return {
      response: `🎓 **Welcome to DIU SmartAdmit — Your Personal Admission Counselor!**\n\nI'll help you find the perfect department at **Daffodil International University** based on your academic background, interests, and career goals.\n\nI'll ask you a few simple questions — no rush, take your time.\n\n${STAGE_QUESTIONS.gpa}`,
      stage: 'gpa',
      profileComplete: false
    };
  }

  if (stage === 'gpa') {
    const gpa = extractSSCGpa(message);
    if (gpa === null) {
      return { response: `I couldn't catch that. Please enter your **SSC GPA** as a number, like **4.50** or **5.00**.`, stage, profileComplete: false };
    }
    profile.sscGpa = gpa;
    profile.completionStage = 'hscGpa';
    await profile.save();
    return { response: `SSC GPA **${gpa}** noted! ✅\n\n${STAGE_QUESTIONS.hscGpa}`, stage: 'hscGpa', profileComplete: false };
  }

  if (stage === 'hscGpa') {
    const gpa = extractSSCGpa(message);
    if (gpa === null) {
      return { response: `Please enter your **HSC GPA** as a number, like **4.75**.`, stage, profileComplete: false };
    }
    profile.hscGpa = gpa;
    profile.completionStage = 'group';
    await profile.save();
    return { response: `HSC GPA **${gpa}** noted! ✅\n\n${STAGE_QUESTIONS.group}`, stage: 'group', profileComplete: false };
  }

  if (stage === 'group') {
    const group = extractGroup(message);
    if (!group) {
      return { response: `Please say **Science**, **Business**, or **Humanities** — which group were you in?`, stage, profileComplete: false };
    }
    profile.group = group;
    profile.completionStage = 'subjects';
    await profile.save();
    return { response: `Got it — **${group}** group! ✅\n\n${STAGE_QUESTIONS.subjects}`, stage: 'subjects', profileComplete: false };
  }

  if (stage === 'subjects') {
    const items = extractList(message);
    profile.favoriteSubjects = items.slice(0, 8);
    profile.completionStage = 'interests';
    await profile.save();
    return { response: `Noted your subjects: **${items.slice(0, 5).join(', ')}** ✅\n\n${STAGE_QUESTIONS.interests}`, stage: 'interests', profileComplete: false };
  }

  if (stage === 'interests') {
    const items = extractList(message);
    profile.interests = items.slice(0, 10);
    profile.completionStage = 'career';
    await profile.save();
    return { response: `Interesting! I've noted your interests. ✅\n\n${STAGE_QUESTIONS.career}`, stage: 'career', profileComplete: false };
  }

  if (stage === 'career') {
    const items = extractList(message);
    profile.careerGoals = items.slice(0, 6);
    profile.completionStage = 'financial';
    await profile.save();
    return { response: `Great career vision! ✅\n\n${STAGE_QUESTIONS.financial}`, stage: 'financial', profileComplete: false };
  }

  if (stage === 'financial') {
    const budget = extractBudget(message);
    if (!budget) {
      return { response: `Please indicate: **Low budget**, **Medium budget**, or **High budget** (or no constraint).`, stage, profileComplete: false };
    }
    profile.financialConstraint = budget;
    profile.scholarshipInterest = budget === 'low' || /scholarship/.test(message.toLowerCase());
    profile.completionStage = 'complete';
    profile.profileComplete = true;
    await profile.save();

    const top3 = await scoreAllDepartments(profile);
    const parentEn = buildParentSummaryEn(top3, profile);
    const parentBn = buildParentSummaryBn(top3, profile);

    await Recommendation.findOneAndDelete({ sessionId });
    await Recommendation.create({
      sessionId,
      profileSnapshot: profile.toObject(),
      topDepartments: top3,
      parentSummaryEn: parentEn,
      parentSummaryBn: parentBn
    });

    const recText = buildRecommendationMessage(top3, profile);
    return { response: recText, stage: 'complete', profileComplete: true, recommendations: top3 };
  }

  if (stage === 'complete') {
    const rec = await Recommendation.findOne({ sessionId });
    if (rec) {
      return {
        response: `Your profile is complete! Here's a summary of your top recommendations:\n\n${buildRecommendationMessage(rec.topDepartments, profile)}`,
        stage: 'complete',
        profileComplete: true,
        recommendations: rec.topDepartments
      };
    }
  }

  return { response: `Let me restart your profile assessment. ${STAGE_QUESTIONS.gpa}`, stage: 'gpa', profileComplete: false };
};

const buildRecommendationMessage = (top3, profile) => {

  if (!top3 || top3.length === 0) {
    return "❌ No suitable department found.";
  }

  const effectiveGpa = Math.min(profile.sscGpa || 0, profile.hscGpa || 0);

  let msg =
`🎯 **Your Personalized Department Recommendations**

Based on your GPA (**${effectiveGpa}**) and your interests, here are your best matches:

`;

  top3.forEach((dept, index) => {

    const medal =
      index === 0
        ? "🥇"
        : index === 1
        ? "🥈"
        : "🥉";

    msg +=
`${medal} **${dept.department} (${dept.code})**

⭐ Score: ${dept.score}

🎯 Confidence: ${dept.confidence}

🏛 Faculty: ${dept.faculty}

⏳ Duration: ${dept.duration}

💰 Tuition Fee:
BDT ${dept.tuitionFee}

💵 Starting Salary:
${dept.salary}

📈 Bangladesh Demand:
${dept.demand}

💼 Career Paths:
${dept.careerPaths.slice(0,4).join(", ")}

🏢 Top Companies:
${dept.companies.join(", ")}

📝 Summary:
${dept.summary}

----------------------------------------

`;

  });

  msg +=
`📄 You can now:

• Download Report
• Parent Mode
• Compare Departments
• Ask any admission question`;

  return msg;

};

module.exports = { processAgentMessage };
