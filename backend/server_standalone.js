/**
 * DIU SmartAdmit - Standalone Backend (No npm dependencies)
 * Runs with: node server_standalone.js
 * Uses only Node.js built-in modules
 * Replace with full Express version when npm is available
 */
const http = require('http');
const url = require('url');
const crypto = require('crypto');
const PORT = 3000;

// ─── In-memory data stores (replaces MongoDB for demo) ──────────────────────
const departments = [
  { code:'CSE', name:'Computer Science & Engineering', faculty:'Engineering', minGPA:4.5, seats:120, tuitionPerSemester:9900, duration:'4 years', description:'Covers algorithms, software engineering, AI, databases, networks, and systems.', careers:['Software Engineer','AI/ML Engineer','Data Scientist','DevOps Engineer'], requiredSubjects:['Physics','Mathematics','Chemistry or Biology'], admissionTestRequired:true, tags:['tech','programming','ai','software'], keywordMatch:['computer','coding','programming','software','tech'], careerMatch:['software engineer','developer','programmer','ai','data scientist'], roadmap:{year1:['C/C++ programming','Data Structures','Discrete Math','Computer Architecture'],year2:['OOP with Java','Database Systems','Web Development','Algorithms'],year3:['Machine Learning','Software Engineering','Internship','Mobile Dev'],year4:['Final Project','Capstone','Portfolio','Job Prep']}, jobRoles:['Full Stack Developer','Data Engineer','AI Researcher','Cloud Architect'], industrySectors:['FinTech','E-Commerce','Healthcare IT','Telecom'] },
  { code:'SWE', name:'Software Engineering', faculty:'Engineering', minGPA:4.5, seats:60, tuitionPerSemester:9900, duration:'4 years', description:'Specialised in software design, architecture, testing, project management, DevOps.', careers:['Software Engineer','QA Engineer','Project Manager','DevOps Engineer'], requiredSubjects:['Physics','Mathematics'], admissionTestRequired:true, tags:['tech','programming','software','engineering'], keywordMatch:['software','engineering','swe','coding','agile','devops'], careerMatch:['software engineer','developer','project manager','devops'], roadmap:{year1:['Programming fundamentals','OOP','Discrete Math','Requirements Eng'],year2:['Software Architecture','Design Patterns','Testing & QA','Databases'],year3:['Agile & Scrum','Cloud Computing','DevOps','Internship'],year4:['Final Project','Capstone','Industry Placement','Soft Skills']}, jobRoles:['Software Developer','QA Tester','Scrum Master','Technical Lead'], industrySectors:['Software Houses','Startups','Enterprise IT','Banking Tech'] },
  { code:'EEE', name:'Electrical & Electronic Engineering', faculty:'Engineering', minGPA:4.5, seats:60, tuitionPerSemester:9900, duration:'4 years', description:'Covers circuit theory, power systems, electronics, signals, embedded systems.', careers:['Electrical Engineer','Telecom Engineer','Embedded Developer'], requiredSubjects:['Physics','Mathematics','Chemistry'], admissionTestRequired:true, tags:['tech','electronics','circuits','power'], keywordMatch:['electrical','electronics','circuit','eee','power','embedded'], careerMatch:['electrical engineer','electronics','telecom','power'], roadmap:{year1:['Circuit Analysis','Engineering Math','Physics','Electronics I'],year2:['Signals & Systems','Digital Electronics','Microprocessors','Power Systems'],year3:['Embedded Systems','Communication','Control Systems','Internship'],year4:['Final Project','Power Distribution','Industry Training','Capstone']}, jobRoles:['Power Engineer','Telecom Specialist','Embedded Developer','PCB Designer'], industrySectors:['Power Sector','Telecom','Manufacturing','Renewable Energy'] },
  { code:'BBA', name:'Business Administration', faculty:'Business & Entrepreneurship', minGPA:3.5, seats:180, tuitionPerSemester:9900, duration:'4 years', description:'Covers management, marketing, finance, accounting, HR, entrepreneurship.', careers:['Business Manager','Entrepreneur','Marketing Executive','Financial Analyst'], requiredSubjects:['Any group accepted'], admissionTestRequired:true, tags:['business','management','finance','marketing'], keywordMatch:['business','management','finance','marketing','hr','accounting','entrepreneur'], careerMatch:['manager','entrepreneur','marketing','finance','business','hr'], roadmap:{year1:['Business Math','Principles of Management','Accounting Basics','Business English'],year2:['Financial Management','Marketing Management','HRM','Business Law'],year3:['Entrepreneurship','Supply Chain','Business Analytics','Internship'],year4:['Strategic Management','Thesis','Industry Project','Capstone']}, jobRoles:['Brand Manager','Financial Analyst','HR Executive','Operations Manager'], industrySectors:['Banking','NGO','FMCG','Consulting','Startups'] },
  { code:'CE', name:'Civil Engineering', faculty:'Engineering', minGPA:4.0, seats:60, tuitionPerSemester:9900, duration:'4 years', description:'Covers structural analysis, geotechnical engineering, transportation, construction.', careers:['Civil Engineer','Structural Designer','Urban Planner'], requiredSubjects:['Physics','Mathematics','Chemistry'], admissionTestRequired:true, tags:['engineering','construction','structural'], keywordMatch:['civil','construction','building','structure','bridge'], careerMatch:['civil engineer','structural','construction','urban planner'], roadmap:{year1:['Engineering Drawing','Surveying','Engineering Math','Fluid Mechanics'],year2:['Structural Analysis','Soil Mechanics','Concrete Technology','Transportation'],year3:['Foundation Design','Steel Structures','AutoCAD','Internship'],year4:['Final Project','Construction Management','Estimation','Capstone']}, jobRoles:['Structural Engineer','Site Engineer','Project Manager','Consultant'], industrySectors:['Real Estate','Government LGED/PWD','Construction Firms','NGO Infrastructure'] },
  { code:'ME', name:'Mechanical Engineering', faculty:'Engineering', minGPA:4.0, seats:60, tuitionPerSemester:9900, duration:'4 years', description:'Covers thermodynamics, fluid mechanics, manufacturing, robotics, CAD/CAM.', careers:['Mechanical Engineer','Robotics Engineer','Production Manager'], requiredSubjects:['Physics','Mathematics','Chemistry'], admissionTestRequired:true, tags:['engineering','robotics','manufacturing'], keywordMatch:['mechanical','machine','robotics','manufacturing','automobile'], careerMatch:['mechanical engineer','robotics','manufacturing','production'], roadmap:{year1:['Engineering Mechanics','Thermodynamics I','Engineering Drawing','Materials Science'],year2:['Fluid Mechanics','Manufacturing Processes','CAD/CAM','Machine Design'],year3:['Robotics','Heat Transfer','Automation','Internship'],year4:['Final Project','Industrial Training','Vibration & Control','Capstone']}, jobRoles:['Production Engineer','Design Engineer','Maintenance Engineer','HVAC Engineer'], industrySectors:['Manufacturing','Automotive','Garments Industry','Energy'] },
  { code:'TE', name:'Textile Engineering', faculty:'Engineering', minGPA:4.0, seats:60, tuitionPerSemester:9900, duration:'4 years', description:'Covers fiber science, yarn technology, fabric manufacturing, dyeing, garment production.', careers:['Textile Engineer','Production Manager','Quality Controller'], requiredSubjects:['Physics','Chemistry','Mathematics'], admissionTestRequired:true, tags:['textile','manufacturing','garment'], keywordMatch:['textile','garment','fabric','fashion','rmo','export'], careerMatch:['textile engineer','garment','production','quality'], roadmap:{year1:['Textile Fibers','Chemistry for Textile','Yarn Manufacturing','Engineering Math'],year2:['Fabric Manufacturing','Dyeing & Printing','Apparel Production','Testing Methods'],year3:['Industrial Textile','Fashion Tech','Merchandising','Internship'],year4:['Final Project','Export Documentation','Supply Chain','Capstone']}, jobRoles:['Production Officer','QC Inspector','Merchandiser','Technical Manager'], industrySectors:['RMG Sector','BGMEA Members','Export-Oriented Factories'] },
  { code:'MCT', name:'Multimedia & Creative Technology', faculty:'Science & IT', minGPA:4.0, seats:60, tuitionPerSemester:9900, duration:'4 years', description:'Covers UI/UX design, animation, game development, digital media, photography.', careers:['UI/UX Designer','Game Developer','Animator','Graphic Designer'], requiredSubjects:['Any group with Math or Arts background'], admissionTestRequired:true, tags:['design','creative','ui','ux','game','animation'], keywordMatch:['design','creative','art','graphics','animation','game','ui','ux'], careerMatch:['designer','animator','game developer','creative','multimedia'], roadmap:{year1:['Design Fundamentals','Drawing & Illustration','Typography','Color Theory'],year2:['UI/UX Design','Motion Graphics','3D Modeling','Web Design'],year3:['Game Development','Video Production','App Design','Internship'],year4:['Portfolio Development','Client Projects','Freelance Skills','Capstone']}, jobRoles:['UX Designer','Motion Designer','Game Artist','Brand Designer'], industrySectors:['Gaming','Advertising','Startups','Film & Media'] },
  { code:'ARCH', name:'Architecture', faculty:'Architecture & Environment Design', minGPA:3.5, seats:40, tuitionPerSemester:9900, duration:'5 years', description:'Covers architectural design, urban planning, building construction, interior design.', careers:['Architect','Urban Designer','Interior Designer'], requiredSubjects:['Mathematics preferred','Portfolio required'], admissionTestRequired:true, tags:['design','creative','architecture','urban'], keywordMatch:['architecture','design','drawing','interior','urban','building'], careerMatch:['architect','interior designer','urban planner','designer'], roadmap:{year1:['Architectural Drawing','Design Studio I','History of Architecture','Building Materials'],year2:['Design Studio II','Structural Systems','Environmental Design','Urban Planning'],year3:['Design Studio III','Landscape Architecture','Digital Tools','Internship'],year4:['Advanced Studio','Sustainable Design','Construction Management','Research'],year5:['Thesis Studio','Professional Practice','Portfolio','Capstone']}, jobRoles:['Licensed Architect','Interior Designer','Urban Planner','Design Professor'], industrySectors:['RAJUK','Real Estate','Consulting Firms','Government Projects'] },
  { code:'PHARM', name:'Pharmacy', faculty:'Allied Health Sciences', minGPA:4.0, seats:50, tuitionPerSemester:9900, duration:'4 years', description:'Covers pharmacology, medicinal chemistry, pharmaceutical technology, clinical pharmacy.', careers:['Pharmacist','Drug Researcher','Clinical Pharmacist'], requiredSubjects:['Biology','Chemistry','Physics or Mathematics'], admissionTestRequired:true, tags:['health','medicine','pharmacy','biology'], keywordMatch:['pharmacy','medicine','drug','health','biology','chemistry','clinical'], careerMatch:['pharmacist','drug researcher','clinical','pharmaceutical','healthcare'], roadmap:{year1:['Pharmaceutical Chemistry','Human Anatomy','Biology','Microbiology'],year2:['Pharmacology I','Pharmaceutics','Medicinal Chemistry','Pathology'],year3:['Clinical Pharmacy','Industrial Pharmacy','Drug Regulation','Internship'],year4:['Thesis Research','Hospital Training','Regulatory Affairs','Capstone']}, jobRoles:['Hospital Pharmacist','Drug Inspector','Clinical Researcher','Medical Sales Rep'], industrySectors:['Hospitals','Pharma Companies (Square, Beximco)','WHO/DGDA','Research'] },
  { code:'ENG', name:'English Language & Literature', faculty:'Humanities & Social Sciences', minGPA:3.0, seats:80, tuitionPerSemester:7500, duration:'4 years', description:'Covers linguistics, literature, creative writing, translation, discourse analysis.', careers:['Teacher','Journalist','Translator','Content Writer','Editor'], requiredSubjects:['Any group accepted'], admissionTestRequired:true, tags:['arts','language','humanities','literature'], keywordMatch:['english','language','literature','writing','journalism','communication','translation'], careerMatch:['teacher','journalist','writer','translator','editor'], roadmap:{year1:['English Phonology','Introduction to Literature','Grammar & Composition','Linguistics Basics'],year2:['British Literature','American Literature','Creative Writing','Translation Studies'],year3:['Discourse Analysis','Applied Linguistics','Media Writing','Internship'],year4:['Research Methodology','Thesis','Professional Communication','Capstone']}, jobRoles:['IELTS Trainer','Content Writer','Copy Editor','Diplomatic Aide','Lecturer'], industrySectors:['Education','Media','NGOs','Embassies','BPO/Call Centers'] }
];

const faqs = [
  { question:'What is the admission deadline?', answer:'Application portal opens October, closes November 30. Test in December, results January. Verify at diu.ac.bd.', category:'deadline', keywords:['deadline','last date','when','date','apply','close'] },
  { question:'What documents are required?', answer:'SSC & HSC marksheets + certificates (original + 2 copies), NID or birth certificate, 4 passport photos, admission test admit card, BDT 500 payment receipt.', category:'documents', keywords:['document','certificate','paper','required','bring','marksheet'] },
  { question:'Is there an admission test?', answer:'Yes. MCQ format, 90 minutes, 100 marks: Math 30, Physics/Chemistry 30, English 20, GK 20. Negative marking -0.25 per wrong answer.', category:'test', keywords:['test','exam','mcq','entrance','syllabus','negative'] },
  { question:'What is the tuition fee at DIU?', answer:'Most programs: BDT 9,900/semester. English Literature: BDT 7,500/semester. Application fee: BDT 500 one-time. Scholarships reduce tuition 25-100%.', category:'fees', keywords:['fee','tuition','cost','taka','bdt','price','how much','diu'] },
  { question:'Are scholarships available at DIU?', answer:'Yes: 100% waiver for GPA 5.0, 50% for GPA 4.5-4.99, 25% for GPA 4.0-4.49. Special quotas for freedom fighters, sports, siblings.', category:'scholarship', keywords:['scholarship','waiver','free','discount','stipend','merit','diu'] },
  { question:'How do I apply?', answer:'Step 1: studentportal.diu.ac.bd. Step 2: Fill form. Step 3: Pay BDT 500. Step 4: Download admit card. Step 5: Appear for test. Step 6: Check merit list. Step 7: Enroll.', category:'process', keywords:['apply','how to','process','steps','register','enroll'] },
  { question:'What is the difference between CSE and SWE?', answer:'CSE covers broader topics: algorithms, systems, networking, AI, hardware. SWE focuses on software lifecycle, design patterns, testing, and project management. Both lead to similar careers but SWE is more industry-focused.', category:'general', keywords:['difference','cse','swe','compare','vs','better','choose'] },
  { question:'Where is DIU located?', answer:'Daffodil International University, Ashulia, Savar, Dhaka-1341. Daffodil Smart City campus with residential facilities.', category:'general', keywords:['location','address','where','campus','savar','ashulia','diu'] },
];

// In-memory session store
const sessions = {};
const profiles = {};
const recommendations = {};
const reports = {};
const popularQuestions = {};

// ─── AI Engine ───────────────────────────────────────────────────────────────
const WEIGHTS = { academic: 0.30, interest: 0.25, career: 0.25, practical: 0.20 };

function scoreAcademic(dept, gpa) {
  if (!gpa) return 50;
  const gap = gpa - dept.minGPA;
  if (gap >= 0.5) return 95;
  if (gap >= 0.25) return 82;
  if (gap >= 0) return 68;
  return 0;
}

function scoreInterest(dept, profile) {
  const all = [...(profile.interests||[]),...(profile.favoriteSubjects||[]),...(profile.skills||[])];
  if (!all.length) return 50;
  let hits = 0;
  for (const i of all) {
    const il = i.toLowerCase();
    if (dept.keywordMatch.some(k => k.includes(il) || il.includes(k))) hits++;
    if (dept.tags.some(t => t.includes(il) || il.includes(t))) hits++;
  }
  return Math.min(100, Math.round((hits / all.length) * 100 + (hits > 0 ? 20 : 0)));
}

function scoreCareer(dept, profile) {
  const goals = profile.careerGoals || [];
  if (!goals.length) return 50;
  let hits = 0;
  for (const g of goals) {
    const gl = g.toLowerCase();
    if (dept.careerMatch.some(k => k.includes(gl) || gl.includes(k))) hits++;
  }
  return Math.min(100, Math.round((hits / goals.length) * 100 + (hits > 0 ? 15 : 0)));
}

function scorePractical(dept, profile) {
  let s = 70;
  if (profile.financialConstraint === 'low' && dept.tuitionPerSemester > 9000) s -= 20;
  if (profile.group === 'Science' && dept.requiredSubjects.some(r => r.toLowerCase().includes('physics'))) s += 15;
  if (profile.group === 'Business' && dept.faculty.toLowerCase().includes('business')) s += 20;
  if (profile.group === 'Humanities' && dept.faculty.toLowerCase().includes('humanities')) s += 20;
  if (profile.group === 'Business' && dept.requiredSubjects.some(r => r.toLowerCase().includes('physics'))) s -= 30;
  if (profile.group === 'Humanities' && dept.requiredSubjects.some(r => r.toLowerCase().includes('physics'))) s -= 30;
  return Math.max(0, Math.min(100, s));
}

function buildRecommendations(profile) {
  const effectiveGpa = Math.min(profile.sscGpa || 0, profile.hscGpa || 0);
  const eligible = departments.filter(d => d.minGPA <= (effectiveGpa || 5));
  const scored = eligible.map(dept => {
    const a = scoreAcademic(dept, effectiveGpa);
    const i = scoreInterest(dept, profile);
    const c = scoreCareer(dept, profile);
    const p = scorePractical(dept, profile);
    const confidence = Math.round(a * WEIGHTS.academic + i * WEIGHTS.interest + c * WEIGHTS.career + p * WEIGHTS.practical);
    const gap = effectiveGpa - dept.minGPA;
    const reasons = [];
    if (a >= 90) reasons.push(`Excellent GPA fit — your ${effectiveGpa} comfortably exceeds the ${dept.minGPA} requirement`);
    else if (a >= 68) reasons.push(`GPA meets the ${dept.minGPA} minimum requirement`);
    if (i >= 80) reasons.push(`Strong interest alignment with ${dept.tags.slice(0,2).join(', ')}`);
    if (c >= 80) reasons.push(`Career goals align with ${dept.careers.slice(0,2).join(' and ')}`);
    if (profile.scholarshipInterest && a >= 80) reasons.push(`High scholarship eligibility based on your GPA`);
    if (!reasons.length) reasons.push(`${dept.name} is a viable option for your profile`);
    const scholarshipChance = a >= 90 ? '50-100% waiver possible' : a >= 70 ? '25-50% waiver possible' : 'Limited scholarship options';
    return { code:dept.code, name:dept.name, faculty:dept.faculty, confidenceScore:confidence, academicAlignment:a, interestAlignment:i, careerAlignment:c, practicalFit:p, reasoning:reasons, careerRoadmap:dept.roadmap||{year1:[],year2:[],year3:[],year4:[]}, jobRoles:dept.jobRoles||[], industryPaths:dept.industrySectors||[], tuitionPerSemester:dept.tuitionPerSemester, scholarshipChance };
  });
  return scored.sort((a,b) => b.confidenceScore - a.confidenceScore).slice(0, 3);
}

function buildParentEn(top3, profile) {
  const t = top3[0];
  return `Dear Parent,

Based on ${profile.name || "your child"}'s academic profile (SSC: ${profile.sscGpa}, HSC: ${profile.hscGpa}) and stated interests, our AI system recommends:

**#1: ${t.name} (${t.code}) — ${t.confidenceScore}% Match**
${t.reasoning[0] || 'Strong academic and career alignment.'}

**Why this department?**
${t.reasoning.join('\n• ')}

**Tuition:** BDT ${t.tuitionPerSemester.toLocaleString()}/semester
**Scholarship:** ${t.scholarshipChance}

**Career Opportunities:**
${t.jobRoles.slice(0,3).map(j=>'• '+j).join('\n')}

**Also Consider:**
• ${top3[1]?.name||''} — ${top3[1]?.confidenceScore||''}% match
• ${top3[2]?.name||''} — ${top3[2]?.confidenceScore||''}% match`;
}

function buildParentBn(top3, profile) {
  const t = top3[0];
  return `প্রিয় অভিভাবক,

আপনার সন্তানের একাডেমিক প্রোফাইল (SSC: ${profile.sscGpa}, HSC: ${profile.hscGpa}) এর উপর ভিত্তি করে আমাদের AI সুপারিশ করছে:

**#১: ${t.name} (${t.code}) — ${t.confidenceScore}% মিল**

টিউশন: প্রতি সেমিস্টারে BDT ${t.tuitionPerSemester.toLocaleString()}
বৃত্তি: ${t.scholarshipChance}

ক্যারিয়ার:
${t.jobRoles.slice(0,3).map(j=>'• '+j).join('\n')}

অন্যান্য বিকল্প:
• ${top3[1]?.name||''} — ${top3[1]?.confidenceScore||''}% মিল
• ${top3[2]?.name||''} — ${top3[2]?.confidenceScore||''}% মিল`;
}

// ─── Agentic Engine ───────────────────────────────────────────────────────────
function extractGpa(msg) {
  const m = msg.match(/\b([0-4]\.\d{1,2}|5\.0{1,2})\b/);
  if (m) { const v = parseFloat(m[1]); if (v >= 0 && v <= 5) return v; }
  return null;
}
function extractGroup(msg) {
  const ml = msg.toLowerCase();
  if (/science|phy|chem|bio|sci/.test(ml)) return 'Science';
  if (/business|commerce|account|finance/.test(ml)) return 'Business';
  if (/human|arts|civic|bangla|history/.test(ml)) return 'Humanities';
  return null;
}
function extractBudget(msg) {
  const ml = msg.toLowerCase();
  if (/low|tight|poor|limited|scholarship|no money/.test(ml)) return 'low';
  if (/medium|moderate|some|middle|okay/.test(ml)) return 'medium';
  if (/high|no problem|afford|fine|no constraint/.test(ml)) return 'high';
  return null;
}
function extractList(msg) {
  return msg.split(/[,،\n]+/).map(s => s.trim()).filter(s => s.length > 1 && s.length < 40);
}

function processAgentMessage(msg, sessionId) {
  if (!profiles[sessionId]) {
    profiles[sessionId] = { sessionId, completionStage:'greeting', profileComplete:false, sscGpa:null, hscGpa:null, group:null, favoriteSubjects:[], skills:[], interests:[], careerGoals:[], financialConstraint:null, scholarshipInterest:null };
  }
  const p = profiles[sessionId];
  const stage = p.completionStage;

  if (stage === 'greeting' || /^start\s+assessment/i.test(msg.trim())) {
    p.completionStage = 'gpa';
    return { response:`🎓 **Welcome to DIU SmartAdmit — Your Personal Admission Counselor!**\n\nI'll help you find the perfect department at **Daffodil International University** based on your GPA, interests, and career goals.\n\nLet's start step by step!\n\n**What is your SSC GPA?** (e.g. 4.50 or 5.00)`, stage:'gpa', profileComplete:false };
  }
  if (stage === 'gpa') {
    const gpa = extractGpa(msg);
    if (!gpa) return { response:`Please enter your **SSC GPA** as a number like **4.50**.`, stage, profileComplete:false };
    p.sscGpa = gpa; p.completionStage = 'hscGpa';
    return { response:`SSC GPA **${gpa}** noted! ✅\n\nWhat is your **HSC GPA**?`, stage:'hscGpa', profileComplete:false };
  }
  if (stage === 'hscGpa') {
    const gpa = extractGpa(msg);
    if (!gpa) return { response:`Please enter your **HSC GPA** as a number like **4.75**.`, stage, profileComplete:false };
    p.hscGpa = gpa; p.completionStage = 'group';
    return { response:`HSC GPA **${gpa}** noted! ✅\n\nWhich academic group were you in?\n\n• **Science** (Physics, Chemistry, Math/Biology)\n• **Business** (Accounting, Finance, Economics)\n• **Humanities** (Bangladesh Studies, Civics, etc.)`, stage:'group', profileComplete:false };
  }
  if (stage === 'group') {
    const group = extractGroup(msg);
    if (!group) return { response:`Please say **Science**, **Business**, or **Humanities**.`, stage, profileComplete:false };
    p.group = group; p.completionStage = 'subjects';
    return { response:`**${group}** group! ✅\n\nWhich subjects do you enjoy most? (e.g. Math, Physics, Programming, English, Art — mention multiple)`, stage:'subjects', profileComplete:false };
  }
  if (stage === 'subjects') {
    p.favoriteSubjects = extractList(msg).slice(0, 8); p.completionStage = 'interests';
    return { response:`Got it! ✅\n\nWhat are your main **interests or hobbies**? (e.g. coding, design, business, writing, electronics...)`, stage:'interests', profileComplete:false };
  }
  if (stage === 'interests') {
    p.interests = extractList(msg).slice(0, 10); p.completionStage = 'career';
    return { response:`Interesting! ✅\n\nWhat are your **career goals**? What kind of work do you see yourself doing in 5 years?`, stage:'career', profileComplete:false };
  }
  if (stage === 'career') {
    p.careerGoals = extractList(msg).slice(0, 6); p.completionStage = 'financial';
    return { response:`Great vision! ✅\n\nLast question: Do you have **budget constraints** for tuition?\n\n• **Low budget** — scholarship is important\n• **Medium budget** — some flexibility\n• **High budget** — no constraint`, stage:'financial', profileComplete:false };
  }
  if (stage === 'financial') {
    const budget = extractBudget(msg);
    if (!budget) return { response:`Please say **Low**, **Medium**, or **High** budget.`, stage, profileComplete:false };
    p.financialConstraint = budget;
    p.scholarshipInterest = budget === 'low' || /scholarship/.test(msg.toLowerCase());
    p.completionStage = 'complete';
    p.profileComplete = true;

    const top3 = buildRecommendations(p);
    recommendations[sessionId] = { sessionId, topDepartments:top3, parentSummaryEn:buildParentEn(top3,p), parentSummaryBn:buildParentBn(top3,p), generatedAt:new Date().toISOString(), profileSnapshot:p };

    const effectiveGpa = Math.min(p.sscGpa||0, p.hscGpa||0);
    let resp = `🎯 **Your Personalised Department Recommendations**\n\nBased on GPA **${effectiveGpa}**, interests, and career goals:\n\n`;
    top3.forEach((d,i) => {
      const medal = ['🥇','🥈','🥉'][i];
      resp += `${medal} **${d.name} (${d.code}) — ${d.confidenceScore}% Match**\n`;
      resp += `• Academic: ${d.academicAlignment}% | Interest: ${d.interestAlignment}% | Career: ${d.careerAlignment}% | Practical: ${d.practicalFit}%\n`;
      resp += `• ${d.reasoning[0]}\n`;
      resp += `• BDT ${d.tuitionPerSemester.toLocaleString()}/sem | ${d.scholarshipChance}\n\n`;
    });
    resp += `\n💡 Type **"Parent mode"** for parent-friendly summary, **"Roadmap for ${top3[0].code}"** for career plan, or **"Download report"** for PDF.`;
    return { response:resp, stage:'complete', profileComplete:true };
  }
  // Complete - switch to free chat
  return null;
}

// ─── Intent detection for free chat ─────────────────────────────────────────
function detectIntent(msg) {
  const m = msg.toLowerCase();
  if (/gpa\s*(is|of|=)?\s*\d/.test(m) || /my\s+gpa/.test(m)) return 'GPA';
  if (/parent\s+mode|bangla|অভিভাবক/.test(m)) return 'PARENT';
  if (/roadmap|career\s+path/.test(m)) return 'ROADMAP';
  if (/list.*depart|all\s+depart|available.*depart/.test(m)) return 'LIST_DEPTS';
  if (/compare|vs\.?\s+|difference\s+between/.test(m)) return 'COMPARE';
  if (/fee|tuition|cost|taka|bdt|how\s+much/.test(m)) return 'FEES';
  if (/scholarship|waiver|stipend|free/.test(m)) return 'SCHOLARSHIP';
  if (/deadline|last\s+date|when.*apply/.test(m)) return 'DEADLINE';
  if (/document|certificate|paper|bring/.test(m)) return 'DOCS';
  if (/admission\s+test|entrance|mcq|exam\s+format/.test(m)) return 'TEST';
  if (/how.*apply|admission\s+process|step.*step/.test(m)) return 'PROCESS';
  if (/^(hi|hello|hey|salam|assalamu)/i.test(msg.trim())) return 'GREETING';
  const code = msg.match(/\b(CSE|SWE|EEE|BBA|CE|ME|TE|MCT|ARCH|PHARM|ENG)\b/);
  if (code) return 'DEPT_' + code[1].toUpperCase();
  return 'UNKNOWN';
}

function buildFreeResponse(msg, sessionId) {
  const intent = detectIntent(msg);
  if (intent === 'GREETING') return `👋 **Hello! Welcome to DIU SmartAdmit!**\n\nI'm your AI-powered Admission Assistant for **Daffodil International University**.\n\nType **"Start Assessment"** for personalised guidance, or ask me anything about admission!`;
  if (intent === 'LIST_DEPTS') {
    let r = '🏛️ **DIU Available Departments**\n\n';
    const byFac = {};
    departments.forEach(d => { if(!byFac[d.faculty]) byFac[d.faculty]=[]; byFac[d.faculty].push(d); });
    for (const [fac,list] of Object.entries(byFac)) {
      r += `**${fac}**\n`;
      list.forEach(d => r += `• **${d.code}** — ${d.name} | Min GPA: ${d.minGPA} | BDT ${d.tuitionPerSemester.toLocaleString()}/sem\n`);
      r += '\n';
    }
    return r;
  }
  if (intent === 'FEES') {
    let r = '💰 **DIU Tuition Fee Structure**\n\n';
    departments.forEach(d => r += `• **${d.code}** — ${d.name}: BDT ${d.tuitionPerSemester.toLocaleString()}/semester\n`);
    r += `\n**Additional:** Application fee BDT 500 (one-time) | Lab fee BDT 1,000-2,000/sem (Engineering)`;
    return r;
  }
  if (intent === 'SCHOLARSHIP') return `🎓 **DIU Scholarship Programs**\n\n• GPA 5.0 (Both SSC & HSC): **100% Tuition Waiver**\n• GPA 4.5-4.99: **50% Waiver**\n• GPA 4.0-4.49: **25% Waiver**\n• Freedom Fighter Family: Full waiver\n• Sibling Discount: 10%\n• Government Science Stipend (GPA ≥ 4.0)\n• Financial Hardship Fund`;
  if (intent === 'DEADLINE') return `📅 **DIU Admission Timeline**\n\n• Portal Opens: October\n• Application Deadline: November 30\n• Admit Card: 1st week December\n• Admission Test: 2nd week December\n• Results: January 1st week\n• Enrollment: January 2nd week\n\n⚠️ Always verify exact dates at diu.ac.bd`;
  if (intent === 'DOCS') return `📄 **Required Documents**\n\n☑️ SSC Marksheet & Certificate (original + 2 copies)\n☑️ HSC Marksheet & Certificate (original + 2 copies)\n☑️ NID or Birth Certificate (copy)\n☑️ 4 passport-size photos\n☑️ Admission Test Admit Card\n☑️ BDT 500 payment receipt`;
  if (intent === 'TEST') return `📝 **Admission Test**\n\nMCQ | 90 mins | 100 marks\n\n| Subject | Marks |\n|---|---|\n| Mathematics | 30 |\n| Physics/Chemistry | 30 |\n| English | 20 |\n| General Knowledge | 20 |\n\n• Correct: +1 | Wrong: -0.25 | Blank: 0\n• No calculators or phones`;
  if (intent === 'PROCESS') return `📋 **Admission Process**\n\n1. Visit studentportal.diu.ac.bd\n2. Fill online application form\n3. Select up to 3 departments\n4. Pay BDT 500 fee\n5. Download admit card\n6. Appear for admission test\n7. Check merit list\n8. Document verification\n9. Pay semester fee & enroll`;
  if (intent === 'PARENT' && recommendations[sessionId]) return `👨‍👩‍👧 **Parent Summary — English**\n\n${recommendations[sessionId].parentSummaryEn}\n\n---\n\n**বাংলা সারসংক্ষেপ:**\n\n${recommendations[sessionId].parentSummaryBn}`;
  if (intent === 'PARENT') return `No recommendations yet. Type **"Start Assessment"** first, then ask for Parent Mode.`;
  if (intent === 'ROADMAP') {
    const code = (msg.match(/\b(CSE|SWE|EEE|BBA|CE|ME|TE|MCT|ARCH|PHARM|ENG)\b/i)||[])[1];
    const d = departments.find(d => d.code === (code||'').toUpperCase());
    if (!d) return `Please mention a department code, e.g. "Roadmap for CSE"`;
    const r = d.roadmap;
    return `🗺️ **${d.name} (${d.code}) Roadmap**\n\n**Year 1 — Foundation**\n${(r.year1||[]).map(x=>'• '+x).join('\n')}\n\n**Year 2 — Core Skills**\n${(r.year2||[]).map(x=>'• '+x).join('\n')}\n\n**Year 3 — Specialisation**\n${(r.year3||[]).map(x=>'• '+x).join('\n')}\n\n**Year 4 — Career Launch**\n${(r.year4||[]).map(x=>'• '+x).join('\n')}\n\n**Jobs:** ${d.jobRoles.join(', ')}\n**Industries:** ${d.industrySectors.join(', ')}`;
  }
  if (intent === 'COMPARE') {
    const codes = [...(msg.matchAll(/\b(CSE|SWE|EEE|BBA|CE|ME|TE|MCT|ARCH|PHARM|ENG)\b/gi))].map(m=>m[1].toUpperCase());
    if (codes.length < 2) return `Please mention two department codes, e.g. "Compare CSE and SWE"`;
    const [d1,d2] = [departments.find(d=>d.code===codes[0]), departments.find(d=>d.code===codes[1])];
    if (!d1||!d2) return `Could not find departments. Check the codes.`;
    return `⚖️ **${d1.code} vs ${d2.code}**\n\n| | **${d1.code}** | **${d2.code}** |\n|---|---|---|\n| Name | ${d1.name} | ${d2.name} |\n| Min GPA | ${d1.minGPA} | ${d2.minGPA} |\n| Seats | ${d1.seats} | ${d2.seats} |\n| Tuition | BDT ${d1.tuitionPerSemester.toLocaleString()} | BDT ${d2.tuitionPerSemester.toLocaleString()} |\n| Duration | ${d1.duration} | ${d2.duration} |\n\n**${d1.code}:** ${d1.description.split('.')[0]}.\n**${d2.code}:** ${d2.description.split('.')[0]}.`;
  }
  // Department-specific
  if (intent.startsWith('DEPT_')) {
    const code = intent.replace('DEPT_','');
    const d = departments.find(x=>x.code===code);
    if (d) return `🏛️ **${d.name} (${d.code})**\n\n${d.description}\n\n**Min GPA:** ${d.minGPA} | **Seats:** ${d.seats} | **Fee:** BDT ${d.tuitionPerSemester.toLocaleString()}/sem\n**Duration:** ${d.duration}\n**Subjects:** ${d.requiredSubjects.join(', ')}\n**Careers:** ${d.careers.join(', ')}\n\nAsk *"Roadmap for ${d.code}"* for the 4-year plan!`;
  }
  // FAQ search
  const words = msg.toLowerCase().replace(/[^\w\s]/g,'').split(/\s+/).filter(w=>w.length>3);
  const faq = faqs.find(f => f.keywords.some(k => words.includes(k)));
  if (faq) return `**${faq.question}**\n\n${faq.answer}`;
  // GPA quick rec
  const gpa = extractGpa(msg);
  if (gpa) {
    const eligible = departments.filter(d=>d.minGPA<=gpa);
    if (!eligible.length) return `GPA **${gpa}** does not meet any department minimum. Lowest is 3.0 (English).`;
    let r = `🎯 **Departments for GPA ${gpa}:**\n\n`;
    eligible.slice(0,5).forEach(d=>{ r+=`• **${d.code}** — ${d.name} | Min: ${d.minGPA}\n`; });
    r+=`\nType **"Start Assessment"** for a full AI analysis with confidence scores!`;
    return r;
  }
  return `I can help with DIU admission questions! Try:\n• *"Start Assessment"* for personalised recommendations\n• *"List all departments"*\n• *"What are the fees?"*\n• *"Tell me about CSE"*\n• *"Compare CSE and SWE"*`;
}

// ─── PDF Generator ────────────────────────────────────────────────────────────
function generatePDF(profile, top3, parentEn) {
  const now = new Date().toLocaleDateString('en-GB',{day:'2-digit',month:'long',year:'numeric'});
  const effectiveGpa = Math.min(profile.sscGpa||0,profile.hscGpa||0);
  const deptCards = top3.map((d,i)=>{
    const medal=['🥇','🥈','🥉'][i];
    const roadmapRows = ['year1','year2','year3','year4'].map((y,j)=>{
      const items=(d.careerRoadmap[y]||[]).slice(0,3).join(', ');
      return `<tr><td style="padding:6px;border:1px solid #e2e8f0;font-weight:600;background:#f8fafc">Year ${j+1}</td><td style="padding:6px;border:1px solid #e2e8f0">${items||'N/A'}</td></tr>`;
    }).join('');
    return `<div style="margin-bottom:18px;padding:16px;border:2px solid ${i===0?'#2563eb':'#e2e8f0'};border-radius:10px;background:${i===0?'#eff6ff':'#fff'}">
      <h3 style="margin:0 0 8px;color:#1e3a8a">${medal} ${d.name} (${d.code}) — <span style="color:#2563eb">${d.confidenceScore}% Match</span></h3>
      <div style="display:flex;gap:8px;margin-bottom:10px;flex-wrap:wrap">
        <span style="background:#dbeafe;color:#1e40af;padding:3px 8px;border-radius:6px;font-size:11px">Academic: ${d.academicAlignment}%</span>
        <span style="background:#dcfce7;color:#166534;padding:3px 8px;border-radius:6px;font-size:11px">Interest: ${d.interestAlignment}%</span>
        <span style="background:#fef3c7;color:#92400e;padding:3px 8px;border-radius:6px;font-size:11px">Career: ${d.careerAlignment}%</span>
        <span style="background:#f3e8ff;color:#6b21a8;padding:3px 8px;border-radius:6px;font-size:11px">Practical: ${d.practicalFit}%</span>
      </div>
      <ul style="margin:0 0 10px;padding-left:18px">${d.reasoning.map(r=>`<li style="margin-bottom:3px;font-size:13px">${r}</li>`).join('')}</ul>
      <p style="margin:0 0 4px;font-size:13px"><strong>Tuition:</strong> BDT ${d.tuitionPerSemester.toLocaleString()}/semester | <strong>Scholarship:</strong> ${d.scholarshipChance}</p>
      <p style="margin:0;font-size:13px"><strong>Jobs:</strong> ${d.jobRoles.slice(0,3).join(', ')}</p>
      ${i===0?`<h4 style="margin:12px 0 6px;color:#1e3a8a">4-Year Career Roadmap</h4><table style="width:100%;border-collapse:collapse;font-size:12px">${roadmapRows}</table>`:''}
    </div>`;
  }).join('');
  const html = `<!DOCTYPE html><html><head><meta charset="UTF-8"><title>SmartAdmit Report</title></head>
<body style="font-family:Arial,sans-serif;margin:0;padding:32px;color:#0f172a;max-width:800px">
  <div style="text-align:center;margin-bottom:28px;padding-bottom:20px;border-bottom:3px solid #2563eb">
    <h1 style="margin:0;color:#2563eb;font-size:26px">🎓 DIU SmartAdmit</h1>
    <p style="margin:4px 0 0;color:#64748b;font-size:14px">AI Admission & Career Guidance Report</p>
    <p style="margin:4px 0 0;color:#94a3b8;font-size:12px">Generated: ${now}</p>
  </div>
  <div style="background:#f8fafc;border:1px solid #e2e8f0;border-radius:10px;padding:18px;margin-bottom:24px">
    <h2 style="margin:0 0 12px;color:#1e3a8a;font-size:16px">📋 Student Profile</h2>
    <table style="width:100%;font-size:13px">
      <tr><td style="padding:4px 0;color:#64748b;width:160px">SSC GPA</td><td>${profile.sscGpa||'N/A'}</td></tr>
      <tr><td style="padding:4px 0;color:#64748b">HSC GPA</td><td>${profile.hscGpa||'N/A'}</td></tr>
      <tr><td style="padding:4px 0;color:#64748b">Effective GPA</td><td><strong>${effectiveGpa}</strong></td></tr>
      <tr><td style="padding:4px 0;color:#64748b">Group</td><td>${profile.group||'N/A'}</td></tr>
      <tr><td style="padding:4px 0;color:#64748b">Interests</td><td>${(profile.interests||[]).join(', ')||'N/A'}</td></tr>
      <tr><td style="padding:4px 0;color:#64748b">Career Goals</td><td>${(profile.careerGoals||[]).join(', ')||'N/A'}</td></tr>
      <tr><td style="padding:4px 0;color:#64748b">Budget</td><td>${profile.financialConstraint||'N/A'}</td></tr>
    </table>
  </div>
  <h2 style="color:#1e3a8a;font-size:16px;margin-bottom:14px">🎯 Top 3 Recommendations</h2>
  ${deptCards}
  <div style="background:#f0fdf4;border:1px solid #bbf7d0;border-radius:10px;padding:18px;margin-top:24px">
    <h2 style="margin:0 0 10px;color:#166534;font-size:15px">👨‍👩‍👧 Parent Summary</h2>
    <pre style="font-family:Arial,sans-serif;font-size:12px;white-space:pre-wrap;line-height:1.6;margin:0;color:#0f172a">${parentEn}</pre>
  </div>
  <div style="margin-top:32px;text-align:center;padding-top:16px;border-top:1px solid #e2e8f0">
    <p style="color:#94a3b8;font-size:11px;margin:0">DIU SmartAdmit AI System — diu.ac.bd</p>
  </div>
</body></html>`;
  return Buffer.from(html).toString('base64');
}

// ─── HTTP Router ───────────────────────────────────────────────────────────────
function sendJSON(res, status, data) {
  res.writeHead(status, { 'Content-Type':'application/json','Access-Control-Allow-Origin':'*','Access-Control-Allow-Methods':'GET,POST,PUT,DELETE,OPTIONS','Access-Control-Allow-Headers':'Content-Type' });
  res.end(JSON.stringify(data));
}

function readBody(req) {
  return new Promise(resolve => {
    let body = '';
    req.on('data', chunk => body += chunk);
    req.on('end', () => { try { resolve(JSON.parse(body||'{}')); } catch { resolve({}); } });
  });
}

const server = http.createServer(async (req, res) => {
  if (req.method === 'OPTIONS') { sendJSON(res, 200, {}); return; }
  const parsed = url.parse(req.url, true);
  const path = parsed.pathname;
  const method = req.method;

  // Health check
  if (method==='GET' && path==='/') {
    sendJSON(res,200,{success:true,message:'DIU SmartAdmit API running (standalone)',version:'2.0.0-standalone',endpoints:{chat:'POST /api/chat',departments:'GET /api/departments',recommend:'POST /api/recommend',faq:'GET /api/faq',profile:'GET /api/profile/:sessionId',report:'POST /api/report',admin:'GET /api/admin/dashboard'}});
    return;
  }

  // POST /api/chat
  if (method==='POST' && path==='/api/chat') {
    const body = await readBody(req);
    const { message, sessionId } = body;
    if (!message || !message.trim()) { sendJSON(res,400,{success:false,message:'Message required'}); return; }
    const sid = sessionId || `sess_${Date.now()}_${Math.random().toString(36).substr(2,8)}`;
    if (!sessions[sid]) sessions[sid] = { messages:[], context:{} };

    let result;
    const profile = profiles[sid];

    if (/^start\s+assessment/i.test(message.trim())) {
      delete profiles[sid]; delete recommendations[sid];
      result = processAgentMessage(message, sid);
    } else if (profile && !profile.profileComplete) {
      const agentResult = processAgentMessage(message, sid);
      result = agentResult || { response:buildFreeResponse(message,sid), intent:'FREE' };
    } else {
      result = { response:buildFreeResponse(message,sid), intent:'FREE' };
    }

    if (!result) result = { response:buildFreeResponse(message,sid), intent:'FREE' };

    sessions[sid].messages.push({role:'user',content:message.trim()});
    sessions[sid].messages.push({role:'assistant',content:result.response});

    // Track popular questions
    const key = message.trim().toLowerCase().slice(0,80);
    popularQuestions[key] = (popularQuestions[key]||0) + 1;

    sendJSON(res,200,{success:true,sessionId:sid,response:result.response,intent:result.intent||'CHAT',timestamp:new Date().toISOString()});
    return;
  }

  // GET /api/departments
  if (method==='GET' && path==='/api/departments') {
    const { minGPA, search } = parsed.query;
    let list = [...departments];
    if (minGPA) list = list.filter(d => d.minGPA <= parseFloat(minGPA));
    if (search) { const s=search.toLowerCase(); list=list.filter(d=>d.code.toLowerCase().includes(s)||d.name.toLowerCase().includes(s)||d.tags.some(t=>t.includes(s))); }
    sendJSON(res,200,{success:true,count:list.length,data:list});
    return;
  }

  // GET /api/departments/:code
  const deptMatch = path.match(/^\/api\/departments\/([A-Za-z]+)$/);
  if (method==='GET' && deptMatch) {
    const d = departments.find(x=>x.code===deptMatch[1].toUpperCase());
    if (!d) { sendJSON(res,404,{success:false,message:'Department not found'}); return; }
    sendJSON(res,200,{success:true,data:d});
    return;
  }

  // POST /api/recommend
  if (method==='POST' && path==='/api/recommend') {
    const body = await readBody(req);
    const gpa = parseFloat(body.gpa||body.sscGpa||0);
    if (isNaN(gpa)||gpa<0||gpa>5) { sendJSON(res,400,{success:false,message:'Valid GPA 0-5 required'}); return; }
    const interests = body.interests || [];
    const mockProfile = { sscGpa:gpa, hscGpa:gpa, interests, careerGoals:[], financialConstraint:'medium', group:'Science', scholarshipInterest:false };
    const recs = buildRecommendations(mockProfile);
    const tier = gpa>=4.5?'Excellent':gpa>=4.0?'Good':gpa>=3.5?'Average':'Below Average';
    sendJSON(res,200,{success:true,gpa,tier,totalEligible:departments.filter(d=>d.minGPA<=gpa).length,recommendations:recs.map(r=>({...r,reason:r.reasoning[0]}))});
    return;
  }

  // GET /api/faq
  if (method==='GET' && path==='/api/faq') {
    const { category, search } = parsed.query;
    let list = [...faqs];
    if (category) list = list.filter(f=>f.category===category);
    if (search) { const s=search.toLowerCase(); list=list.filter(f=>f.question.toLowerCase().includes(s)||f.keywords.some(k=>k.includes(s))); }
    sendJSON(res,200,{success:true,count:list.length,data:list.map((f,i)=>({...f,_id:`faq_${i}`,views:0,isActive:true}))});
    return;
  }

  // GET /api/faq/meta/categories
  if (method==='GET' && path==='/api/faq/meta/categories') {
    sendJSON(res,200,{success:true,data:[...new Set(faqs.map(f=>f.category))]});
    return;
  }

  // GET /api/profile/:sessionId
  const profileMatch = path.match(/^\/api\/profile\/([^/]+)$/);
  if (method==='GET' && profileMatch) {
    const p = profiles[profileMatch[1]];
    if (!p) { sendJSON(res,404,{success:false,message:'Profile not found'}); return; }
    sendJSON(res,200,{success:true,data:p});
    return;
  }

  // GET /api/profile/:sessionId/recommendation
  const recMatch = path.match(/^\/api\/profile\/([^/]+)\/recommendation$/);
  if (method==='GET' && recMatch) {
    const r = recommendations[recMatch[1]];
    if (!r) { sendJSON(res,404,{success:false,message:'No recommendation found. Complete the assessment first.'}); return; }
    sendJSON(res,200,{success:true,data:r});
    return;
  }

  // PUT /api/profile/:sessionId
  const profilePutMatch = path.match(/^\/api\/profile\/([^/]+)$/);
  if (method==='PUT' && profilePutMatch) {
    const body = await readBody(req);
    const sid = profilePutMatch[1];
    if (!profiles[sid]) profiles[sid] = { sessionId:sid, completionStage:'greeting', profileComplete:false, sscGpa:null, hscGpa:null, group:null, favoriteSubjects:[], skills:[], interests:[], careerGoals:[], financialConstraint:null, scholarshipInterest:null };
    Object.assign(profiles[sid], body);
    sendJSON(res,200,{success:true,data:profiles[sid]});
    return;
  }

  // DELETE /api/profile/:sessionId
  if (method==='DELETE' && profileMatch) {
    delete profiles[profileMatch[1]];
    delete recommendations[profileMatch[1]];
    sendJSON(res,200,{success:true,message:'Profile reset'});
    return;
  }

  // POST /api/report
  if (method==='POST' && path==='/api/report') {
    const body = await readBody(req);
    const { sessionId } = body;
    if (!sessionId) { sendJSON(res,400,{success:false,message:'sessionId required'}); return; }
    const profile = profiles[sessionId];
    const rec = recommendations[sessionId];
    if (!rec||!profile) { sendJSON(res,404,{success:false,message:'Complete the assessment first.'}); return; }
    const pdf = generatePDF(profile, rec.topDepartments, rec.parentSummaryEn);
    reports[sessionId] = { sessionId, studentName:profile.name||'Student', pdfBase64:pdf, generatedAt:new Date().toISOString() };
    sendJSON(res,200,{success:true,reportId:`report_${sessionId}`,studentName:profile.name||'Student',pdfBase64:pdf,generatedAt:reports[sessionId].generatedAt});
    return;
  }

  // GET /api/report/:sessionId
  const reportMatch = path.match(/^\/api\/report\/([^/]+)$/);
  if (method==='GET' && reportMatch) {
    const r = reports[reportMatch[1]];
    if (!r) { sendJSON(res,404,{success:false,message:'Report not found. Generate via POST /api/report first.'}); return; }
    sendJSON(res,200,{success:true,pdfBase64:r.pdfBase64,studentName:r.studentName,generatedAt:r.generatedAt});
    return;
  }

  // GET /api/admin/dashboard
  if (method==='GET' && path==='/api/admin/dashboard') {
    const topQ = Object.entries(popularQuestions).sort((a,b)=>b[1]-a[1]).slice(0,5).map(([q,c])=>({question:q,count:c}));
    sendJSON(res,200,{success:true,stats:{totalProfiles:Object.keys(profiles).length,completedProfiles:Object.values(profiles).filter(p=>p.profileComplete).length,totalRecommendations:Object.keys(recommendations).length,totalReports:Object.keys(reports).length,totalChatSessions:Object.keys(sessions).length,topQuestions:topQ}});
    return;
  }

  // GET /api/admin/profiles
  if (method==='GET' && path==='/api/admin/profiles') {
    sendJSON(res,200,{success:true,total:Object.keys(profiles).length,data:Object.values(profiles)});
    return;
  }

  // GET /api/admin/recommendations
  if (method==='GET' && path==='/api/admin/recommendations') {
    sendJSON(res,200,{success:true,total:Object.keys(recommendations).length,data:Object.values(recommendations).map(r=>({...r,parentSummaryEn:r.parentSummaryEn.slice(0,100)+'...',pdfBase64:undefined}))});
    return;
  }

  // GET /api/admin/questions
  if (method==='GET' && path==='/api/admin/questions') {
    const q = Object.entries(popularQuestions).sort((a,b)=>b[1]-a[1]).slice(0,30).map(([question,count])=>({question,count}));
    sendJSON(res,200,{success:true,data:q});
    return;
  }

  // GET /api/chat/history/:sessionId
  const historyMatch = path.match(/^\/api\/chat\/history\/([^/]+)$/);
  if (method==='GET' && historyMatch) {
    const s = sessions[historyMatch[1]];
    if (!s) { sendJSON(res,404,{success:false,message:'Session not found'}); return; }
    sendJSON(res,200,{success:true,sessionId:historyMatch[1],messages:s.messages,context:s.context});
    return;
  }

  // DELETE /api/chat/history/:sessionId
  if (method==='DELETE' && historyMatch) {
    delete sessions[historyMatch[1]];
    delete profiles[historyMatch[1]];
    sendJSON(res,200,{success:true,message:'Cleared'});
    return;
  }

  sendJSON(res,404,{success:false,message:`Route not found: ${method} ${path}`});
});

server.listen(PORT, () => {
  console.log(`\n✅ DIU SmartAdmit Standalone Server running on http://localhost:${PORT}`);
  console.log('📦 Mode: Standalone (no MongoDB/npm required)');
  console.log('🚀 All 18+ API endpoints active\n');
});

module.exports = server;
