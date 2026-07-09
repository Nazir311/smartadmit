const OpenAI = require('openai');
const Department = require('../models/Department');
const FAQ = require('../models/FAQ');
const Recommendation = require('../models/Recommendation');
const StudentProfile = require('../models/StudentProfile');
const PopularQuestion = require('../models/PopularQuestion');

let openai = null;
if (process.env.OPENAI_API_KEY && process.env.OPENAI_API_KEY !== 'your_openai_api_key_here') {
  openai = new OpenAI({ apiKey: process.env.OPENAI_API_KEY });
}

const INTENTS = {
  GPA_RECOMMENDATION: [/gpa\s*(is|of|=|:)?\s*\d+\.?\d*/i, /my\s+gpa/i, /i\s+(got|have|scored?)\s+\d+\.?\d*/i],
  DEPARTMENT_INFO: [/about\s+(cse|eee|swe|bba|me|ce|te|ece|arch|pharm|eng|mct)\b/i, /details\s+(of|about)\s+(cse|eee|swe|bba)/i, /what\s+is\s+(cse|swe|eee|bba)/i],
  DEPT_COMPARE: [/difference\s+between/i, /compare\s+/i, /vs\.?\s+/i, /better.*(cse|swe|eee|bba)/i, /(cse|swe|eee|bba).*better/i],
  DEPARTMENT_LIST: [/(list|show|what are|available)\s+(all\s+)?(available\s+)?departments/i, /all\s+departments/i, /what\s+can\s+i\s+study/i],
  ROADMAP: [/roadmap/i, /career\s+path/i, /year\s+(1|2|3|4|by\s+year)/i, /what\s+to\s+(learn|study)\s+in/i],
  PARENT_MODE: [/parent\s+mode/i, /explain\s+(to|for)\s+(my\s+)?parent/i, /bangla\s+(version|summary)/i, /parent\s+summary/i],
  RECOMMENDATION_RESULT: [/show\s+(my\s+)?recommendation/i, /what\s+did\s+you\s+recommend/i, /my\s+result/i, /top\s+department/i],
  ADMISSION_PROCESS: [/how\s+to\s+(apply|get\s+admission)/i, /admission\s+(process|procedure|steps)/i, /how\s+(do|can)\s+i\s+(apply|register|enroll)/i],
  DEADLINE: [/deadline/i, /last\s+date/i, /when\s+(is|to|can)\s+(apply|admission)/i],
  FEE_INFO: [/\bfees?\b/i, /tuition/i, /\bcost\b/i, /how\s+much/i, /\btaka\b/i, /\bbdt\b/i],
  SCHOLARSHIP: [/scholarship/i, /financial\s+aid/i, /\bwaiver\b/i, /\bstipend\b/i],
  DOCUMENT_INFO: [/\bdocument/i, /\bcertificate/i, /what\s+to\s+bring/i, /required\s+papers/i],
  ADMISSION_TEST: [/admission\s+test/i, /entrance\s+exam/i, /\bmcq\b/i, /exam\s+format/i, /negative\s+marking/i],
  GREETING: [/^(hi|hello|hey|salam|assalamu)\b/i, /^(good\s+(morning|afternoon|evening))\b/i],
  HELP: [/what\s+can\s+you\s+do/i, /how\s+can\s+you\s+help/i, /\bhelp\b/i, /features/i]
};

const detectIntent = (msg) => {
  for (const [intent, patterns] of Object.entries(INTENTS)) {
    for (const p of patterns) { if (p.test(msg)) return intent; }
  }
  return 'UNKNOWN';
};

const extractGPA = (msg) => {
  const m = msg.match(/\b([0-4]\.\d{1,2}|5\.0{1,2})\b/);
  if (m) { const v = parseFloat(m[1]); if (v >= 0 && v <= 5) return v; }
  return null;
};

const extractCode = (msg) => {
  const m = msg.match(/\b(CSE|SWE|EEE|BBA|ME|CE|TE|ECE|ARCH|PHARM|ENG|MCT)\b/i);
  return m ? m[1].toUpperCase() : null;
};

const trackQuestion = async (message, intent) => {
  try {
    const key = message.trim().toLowerCase().slice(0, 100);
    await PopularQuestion.findOneAndUpdate({ question: key }, { $inc: { count: 1 }, $set: { intent } }, { upsert: true });
  } catch (_) {}
};

const buildGreeting = () => `👋 **Hello! Welcome to DIU SmartAdmit!**

I'm your AI-powered Admission & Career Guidance Assistant for **Daffodil International University**.

**What I can do:**
• 🤖 **Agent Mode** — I'll guide you step-by-step to find your perfect department
• 💬 **Free Chat** — Ask any admission question directly
• 🎯 **Confidence Scoring** — AI scoring across 4 dimensions
• 👨‍👩‍👧 **Parent Mode** — Simple summaries in English & Bangla
• 📊 **Career Roadmap** — Year-by-year plan
• 📄 **PDF Report** — Downloadable admission report

Type **"Start Assessment"** for personalized guidance, or just ask me anything!`;

const buildProcessResponse = () => `📋 **DIU Admission Process — Step by Step**

**Step 1 — Check Eligibility**
Verify your SSC and HSC GPA meets the department minimum.

**Step 2 — Online Application**
Visit studentportal.diu.ac.bd → Register → Fill form → Select up to 3 departments.

**Step 3 — Pay Application Fee**
BDT 500 via bKash, Nagad, Rocket, or bank. Keep the receipt.

**Step 4 — Download Admit Card**
Available 3–5 days before the test on the portal.

**Step 5 — Admission Test**
MCQ format, 90 minutes, 100 marks (Math 30, Physics/Chemistry 30, English 20, GK 20). Negative marking: -0.25.

**Step 6 — Merit List**
Published within 2 weeks on the portal and via SMS.

**Step 7 — Document Verification**
Bring originals to the admission office on the assigned date.

**Step 8 — Enrollment**
Pay semester fee → Collect student ID → Classes begin.

➡️ *Tell me your GPA and I'll check which departments you qualify for!*`;

const buildFeeResponse = async () => {
  const depts = await Department.find({ isActive: true }).select('code name tuitionPerSemester').sort({ tuitionPerSemester: 1 });
  const list = depts.map(d => `• **${d.code}** — ${d.name}: BDT ${d.tuitionPerSemester.toLocaleString()}/semester`).join('\n');
  return `💰 **DIU Tuition Fee Structure**\n\n${list}\n\n**Additional Costs:**\n• Application fee: BDT 500 (one-time)\n• Library fee: BDT 500/year\n• Lab fee: BDT 1,000–2,000/sem (Engineering)\n• Student ID: BDT 200\n\n🎓 Scholarships can reduce tuition by **25%–100%**. Ask me about scholarships!`;
};

const buildScholarshipResponse = () => `🎓 **DIU Scholarship Programs**

**Merit-Based Tuition Waiver:**
| GPA (Both SSC & HSC) | Waiver |
|---|---|
| 5.0 (Golden A+) | **100% — Free!** |
| 4.5 – 4.99 | **50% waiver** |
| 4.0 – 4.49 | **25% waiver** |

**Special Scholarships:**
• 🏅 Freedom Fighter Family — Full waiver
• 👨‍👩‍👦 Sibling Discount — 10% if a sibling is enrolled
• 🇧🇩 Government Science Stipend — For HSC Science GPA ≥ 4.0
• 🆘 Financial Hardship Fund — Need-based, requires income certificate
• 🏆 Sports/Cultural Quota — Excellence-based

**Retention:** Maintain CGPA ≥ 3.5 each semester to keep scholarship.`;

const buildDeadlineResponse = () => `📅 **DIU Admission Timeline**

| Phase | Typical Date |
|---|---|
| Application Portal Opens | October (1st week) |
| Application Deadline | November 30 |
| Admit Card Available | 1st week of December |
| Admission Test | 2nd week of December |
| Result Published | January (1st week) |
| Document Verification | January (2nd week) |
| Semester Fees & Enrollment | January (3rd week) |
| Classes Begin | February |

⚠️ Always verify exact dates at **diu.ac.bd** — dates vary by year.`;

const buildDocumentResponse = () => `📄 **Required Documents for DIU Admission**

**Academic Documents:**
☑️ SSC Marksheet & Certificate — original + 2 attested copies
☑️ HSC Marksheet & Certificate — original + 2 attested copies
☑️ SSC & HSC Admit Cards

**Identity Documents:**
☑️ National ID OR Birth Certificate — photocopy
☑️ Guardian's NID — photocopy
☑️ 4 passport-size photos (white background, recent)

**Admission Documents:**
☑️ Printed Admission Test Admit Card
☑️ Bank payment receipt — BDT 500 application fee
☑️ Filled and printed Application Form

**For Architecture only:**
☑️ Portfolio of 10+ drawings/design works

⚠️ All originals are required for physical verification. Bring them in a folder.`;

const buildTestResponse = () => `📝 **DIU Admission Test Details**

**Format:** MCQ | 90 minutes | 100 marks

| Subject | Questions | Marks |
|---|---|---|
| Mathematics | 30 | 30 |
| Physics / Chemistry | 30 | 30 |
| English | 20 | 20 |
| General Knowledge | 20 | 20 |

**Marking:** ✅ +1 correct | ❌ -0.25 wrong | ⬜ 0 blank

**Rules:**
• Bring admit card + NID/birth certificate
• Arrive 30 minutes early
• No calculators, phones, or smartwatches
• Blue/black ballpoint pen only

**Syllabus:** HSC level — Class 11–12 Math, Physics/Chemistry, English grammar/comprehension, Bangladesh & international GK.`;

const buildDeptListResponse = async () => {
  const depts = await Department.find({ isActive: true }).sort({ minGPA: -1 });
  const byFaculty = {};
  for (const d of depts) {
    if (!byFaculty[d.faculty]) byFaculty[d.faculty] = [];
    byFaculty[d.faculty].push(d);
  }
  let r = `🏛️ **DIU Available Departments**\n\n`;
  for (const [fac, list] of Object.entries(byFaculty)) {
    r += `**${fac}**\n`;
    for (const d of list) r += `• **${d.code}** — ${d.name} | Min GPA: ${d.minGPA} | ${d.seats} seats | BDT ${d.tuitionPerSemester.toLocaleString()}/sem\n`;
    r += '\n';
  }
  r += `\n💡 Type *"Start Assessment"* for personalized recommendations, or ask about any department!`;
  return r;
};

const buildDeptDetailResponse = async (code) => {
  const d = await Department.findOne({ code, isActive: true });
  if (!d) return `Department **${code}** not found. Available: CSE, SWE, EEE, MCT, CE, ME, TE, BBA, ARCH, PHARM, ENG`;
  return `🏛️ **${d.name} (${d.code})**\n\n📖 ${d.description}\n\n**Requirements:**\n• Min GPA: **${d.minGPA}** (SSC & HSC)\n• Subjects: ${d.requiredSubjects.join(', ')}\n• Admission Test: ${d.admissionTestRequired ? 'Required' : 'Not required'}\n\n**Details:**\n• Duration: ${d.duration} | Seats: ${d.seats} | Fee: BDT ${d.tuitionPerSemester.toLocaleString()}/sem\n• Faculty: ${d.faculty}\n\n**Careers:** ${d.careers.slice(0, 4).join(', ')}\n\n**Job Roles:** ${(d.jobRoles || []).slice(0, 4).join(', ')}\n\n**Industry:** ${(d.industrySectors || []).slice(0, 3).join(', ')}\n\n➡️ Ask *"Roadmap for ${d.code}"* to see the year-by-year learning plan!`;
};

const buildCompareResponse = async (msg) => {
  const codes = [];
  const m = msg.match(/\b(CSE|SWE|EEE|BBA|ME|CE|TE|MCT|ARCH|PHARM|ENG)\b/gi);
  if (m) codes.push(...m.map(c => c.toUpperCase()).filter((v, i, a) => a.indexOf(v) === i).slice(0, 2));
  if (codes.length < 2) return `Please mention two department codes to compare, e.g. *"Compare CSE and SWE"*`;
  const [d1, d2] = await Promise.all([Department.findOne({ code: codes[0] }), Department.findOne({ code: codes[1] })]);
  if (!d1 || !d2) return `Could not find one or both departments. Please check the codes.`;
  return `⚖️ **${d1.code} vs ${d2.code}**\n\n| | **${d1.code}** | **${d2.code}** |\n|---|---|---|\n| Name | ${d1.name} | ${d2.name} |\n| Min GPA | ${d1.minGPA} | ${d2.minGPA} |\n| Seats | ${d1.seats} | ${d2.seats} |\n| Tuition | BDT ${d1.tuitionPerSemester.toLocaleString()} | BDT ${d2.tuitionPerSemester.toLocaleString()} |\n| Duration | ${d1.duration} | ${d2.duration} |\n| Faculty | ${d1.faculty} | ${d2.faculty} |\n\n**${d1.code} Career Paths:** ${d1.careers.slice(0, 3).join(', ')}\n**${d2.code} Career Paths:** ${d2.careers.slice(0, 3).join(', ')}\n\n**Key Difference:** ${d1.description.split('.')[0]}. Whereas ${d2.description.split('.')[0]}.\n\n💡 Type *"Start Assessment"* to find which one suits YOU better based on your GPA and interests!`;
};

const buildRoadmapResponse = async (msg) => {
  const code = extractCode(msg);
  if (!code) return `Please mention a department code for the roadmap, e.g. *"Roadmap for CSE"*`;
  const d = await Department.findOne({ code, isActive: true });
  if (!d || !d.roadmap) return `Roadmap not available for **${code}**.`;
  const r = d.roadmap;
  return `🗺️ **${d.name} (${d.code}) — Career Roadmap**\n\n**Year 1 — Foundation**\n${(r.year1 || []).map(x => `• ${x}`).join('\n')}\n\n**Year 2 — Core Skills**\n${(r.year2 || []).map(x => `• ${x}`).join('\n')}\n\n**Year 3 — Specialization & Internship**\n${(r.year3 || []).map(x => `• ${x}`).join('\n')}\n\n**Year 4 — Career Launch**\n${(r.year4 || []).map(x => `• ${x}`).join('\n')}\n\n**Top Job Roles:** ${(d.jobRoles || []).join(', ')}\n**Industry Sectors:** ${(d.industrySectors || []).join(', ')}`;
};

const buildParentModeResponse = async (sessionId) => {
  const rec = await Recommendation.findOne({ sessionId });
  if (!rec) return `No recommendations found yet. Please complete the assessment first by typing *"Start Assessment"*.`;
  return `👨‍👩‍👧 **Parent Summary — English**\n\n${rec.parentSummaryEn}\n\n---\n\n**বাংলা সারসংক্ষেপ:**\n\n${rec.parentSummaryBn}`;
};

const buildGPARecommendationResponse = async (gpa) => {
  const eligible = await Department.find({ minGPA: { $lte: gpa }, isActive: true }).sort({ minGPA: -1 });
  if (eligible.length === 0) return `GPA **${gpa}** does not meet the minimum requirement for any department. Minimum is 3.0 (English) or 3.5 (BBA, Architecture). Contact the admission office for special quota options.`;
  const tier = gpa >= 4.5 ? '🌟 Excellent' : gpa >= 4.0 ? '✅ Good' : gpa >= 3.5 ? '👍 Average' : '📌 Basic';
  let r = `🎯 **Departments You Can Apply For (GPA: ${gpa} — ${tier})**\n\nYou qualify for **${eligible.length} departments**:\n\n`;
  eligible.slice(0, 6).forEach(d => {
    const gap = gpa - d.minGPA;
    const label = gap >= 0.5 ? '⭐ Strong' : gap >= 0.25 ? '✅ Good' : '🟡 Borderline';
    r += `**${d.code}** — ${d.name} | ${label} | Min: ${d.minGPA} | BDT ${d.tuitionPerSemester.toLocaleString()}/sem\n`;
  });
  r += `\n💡 Type *"Start Assessment"* for a full AI analysis with confidence scores and career roadmap!`;
  return r;
};

const searchFAQ = async (msg) => {
  const words = msg.toLowerCase().replace(/[^\w\s]/g, '').split(/\s+/).filter(w => w.length > 3);
  if (!words.length) return null;
  const faq = await FAQ.findOneAndUpdate({ keywords: { $in: words }, isActive: true }, { $inc: { views: 1 } }, { new: true });
  return faq ? `**${faq.question}**\n\n${faq.answer}` : null;
};

const getOpenAIResponse = async (message, history) => {
  if (!openai) return `I don't have a specific answer for that. For accurate details, visit **diu.ac.bd** or contact the DIU admission office.\n\nTry asking about: departments, GPA requirements, fees, scholarships, or the admission process.`;
  try {
    const completion = await openai.chat.completions.create({
      model: 'gpt-3.5-turbo',
      messages: [
        { role: 'system', content: 'You are SmartAdmit, an AI admission assistant for Daffodil International University (DIU) in Bangladesh. Answer admission-related questions accurately and concisely. Keep responses under 300 words. Use markdown.' },
        ...history.slice(-8),
        { role: 'user', content: message }
      ],
      max_tokens: 500,
      temperature: 0.6
    });
    return completion.choices[0].message.content;
  } catch (err) {
    console.error('OpenAI error:', err.message);
    return `I'm having trouble connecting right now. Please try again shortly or contact the DIU admission office.`;
  }
};

const processMessage = async (message, context, history, sessionId) => {
  const intent = detectIntent(message);
  const gpa = extractGPA(message);
  const updatedContext = { ...context };
  if (gpa !== null) updatedContext.gpa = gpa;

  await trackQuestion(message, intent);

  if (/^start\s+assessment/i.test(message.trim())) {
    const { processAgentMessage } = require('./agentEngine');
    await StudentProfile.findOneAndDelete({ sessionId });
    const result = await processAgentMessage(message, sessionId);
    return { response: result.response, intent: 'AGENT_START', context: updatedContext };
  }

  if (/parent\s+mode|bangla\s+(version|summary)|parent\s+summary/i.test(message)) {
    return { response: await buildParentModeResponse(sessionId), intent: 'PARENT_MODE', context: updatedContext };
  }

  if (/roadmap/i.test(message) || /career\s+path/i.test(message)) {
    return { response: await buildRoadmapResponse(message), intent: 'ROADMAP', context: updatedContext };
  }

  if (intent === 'GREETING') return { response: buildGreeting(), intent, context: updatedContext };
  if (intent === 'HELP') return { response: buildGreeting(), intent, context: updatedContext };
  if (intent === 'ADMISSION_PROCESS') return { response: buildProcessResponse(), intent, context: updatedContext };
  if (intent === 'DEADLINE') return { response: buildDeadlineResponse(), intent, context: updatedContext };
  if (intent === 'FEE_INFO') return { response: await buildFeeResponse(), intent, context: updatedContext };
  if (intent === 'SCHOLARSHIP') return { response: buildScholarshipResponse(), intent, context: updatedContext };
  if (intent === 'DOCUMENT_INFO') return { response: buildDocumentResponse(), intent, context: updatedContext };
  if (intent === 'ADMISSION_TEST') return { response: buildTestResponse(), intent, context: updatedContext };
  if (intent === 'DEPARTMENT_LIST') return { response: await buildDeptListResponse(), intent, context: updatedContext };
  if (intent === 'DEPT_COMPARE') return { response: await buildCompareResponse(message), intent, context: updatedContext };

  if (intent === 'GPA_RECOMMENDATION' && gpa !== null) {
    return { response: await buildGPARecommendationResponse(gpa), intent, context: updatedContext };
  }

  if (intent === 'DEPARTMENT_INFO') {
    const code = extractCode(message);
    if (code) return { response: await buildDeptDetailResponse(code), intent, context: updatedContext };
  }

  const code = extractCode(message);
  if (code) return { response: await buildDeptDetailResponse(code), intent: 'DEPARTMENT_INFO', context: updatedContext };

  const faq = await searchFAQ(message);
  if (faq) return { response: faq, intent: 'FAQ', context: updatedContext };

  const ai = await getOpenAIResponse(message, history);
  return { response: ai, intent: 'AI_FALLBACK', context: updatedContext };
};

module.exports = { processMessage, detectIntent, extractGPA };
