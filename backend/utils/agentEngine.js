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
  const top = top3[0];
  const name = profile.name || 'your child';
  return `Dear Parent,

Based on ${name}'s academic profile (SSC: ${profile.sscGpa}, HSC: ${profile.hscGpa}) and interests, our AI system recommends:

**#1: ${top.name} (${top.code}) — ${top.confidenceScore}% Match**
${top.reasoning[0] || 'Strong academic and career alignment.'}

**Why this department?**
${top.reasoning.join(' • ')}

**Tuition:** BDT ${top.tuitionPerSemester.toLocaleString()} per semester
**Scholarship Chance:** ${top.scholarshipChance}

**Career Opportunities:**
${top.jobRoles.slice(0, 3).map(j => `• ${j}`).join('\n')}

**Also Consider:**
• ${top3[1]?.name || ''} — ${top3[1]?.confidenceScore || ''}% match
• ${top3[2]?.name || ''} — ${top3[2]?.confidenceScore || ''}% match

This recommendation is based on GPA, interests, career goals, and financial situation. We encourage you to discuss these options with your child.`;
};

const buildParentSummaryBn = (top3, profile) => {
  const top = top3[0];
  return `প্রিয় অভিভাবক,

আপনার সন্তানের একাডেমিক প্রোফাইল (SSC: ${profile.sscGpa}, HSC: ${profile.hscGpa}) এবং আগ্রহের উপর ভিত্তি করে আমাদের AI সিস্টেম সুপারিশ করছে:

**#১: ${top.name} (${top.code}) — ${top.confidenceScore}% মিল**

**কেন এই বিভাগ?**
• একাডেমিক যোগ্যতা ভালোভাবে মিলে যায়
• ক্যারিয়ার লক্ষ্যের সাথে সামঞ্জস্যপূর্ণ
• ভবিষ্যতে ভালো চাকরির সুযোগ রয়েছে

**টিউশন ফি:** প্রতি সেমিস্টারে BDT ${top.tuitionPerSemester.toLocaleString()}
**বৃত্তির সুযোগ:** ${top.scholarshipChance}

**ক্যারিয়ার সুযোগ:**
${top.jobRoles.slice(0, 3).map(j => `• ${j}`).join('\n')}

**অন্যান্য বিকল্প:**
• ${top3[1]?.name || ''} — ${top3[1]?.confidenceScore || ''}% মিল
• ${top3[2]?.name || ''} — ${top3[2]?.confidenceScore || ''}% মিল

এই পরামর্শটি GPA, আগ্রহ, ক্যারিয়ার লক্ষ্য এবং আর্থিক পরিস্থিতির উপর ভিত্তি করে তৈরি।`;
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
  const effectiveGpa = Math.min(profile.sscGpa || 0, profile.hscGpa || 0);
  let msg = `🎯 **Your Personalized Department Recommendations**\n\nBased on your GPA of **${effectiveGpa}**, interests, and career goals:\n\n`;

  top3.forEach((dept, i) => {
    const medal = i === 0 ? '🥇' : i === 1 ? '🥈' : '🥉';
    msg += `${medal} **${dept.name} (${dept.code}) — ${dept.confidenceScore}% Match**\n`;
    msg += `• Academic: ${dept.academicAlignment}% | Interest: ${dept.interestAlignment}% | Career: ${dept.careerAlignment}% | Practical: ${dept.practicalFit}%\n`;
    msg += `• ${dept.reasoning[0]}\n`;
    msg += `• Tuition: BDT ${dept.tuitionPerSemester.toLocaleString()}/sem | ${dept.scholarshipChance}\n\n`;
  });

  msg += `\n💡 **What would you like to do next?**\n• Ask *"Show roadmap for CSE"* to see the 4-year plan\n• Ask *"Parent mode"* to get a parent-friendly summary\n• Ask *"Download report"* to get a PDF\n• Ask any free question about DIU admission`;
  return msg;
};

module.exports = { processAgentMessage };
