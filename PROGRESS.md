# SmartAdmit - progress & handoff (read this first in a new chat)

Project: DIU SmartAdmit (AI admission + career guidance). Owner: Fateha Sultana Esha's group (SE331 / proposal "Smart Admit 2.0").
Rule: guidance only, never official decisions. Eligibility = explicit rules; chat = RAG from verified docs only.
Folder: /home/claude/smartadmit  (backend/ FastAPI, mobile/ Expo React Native, data_in/ RAW PRIVATE files - never publish)

## DONE
- [x] Backend (FastAPI + Mongo/mongomock): auth/JWT/reset, profile, programs, scoring recommender, eligibility, scholarships,
      careers, RAG chat (TF-IDF retrieval, LLM optional), parent mode (student approves), notifications, PDF report,
      document upload + OCR, admin CRUD + CSV import. 50 tests pass: `cd backend && python3 -m pytest -q`
- [x] Real department data loaded from user's Excel -> backend/data/real/programs.csv (33 programs)
- [x] Student survey anonymised -> backend/data/real/students_anonymized.csv; experiment says: too small (38) to train a model; keep rule-based scoring.

## Stage 3 mobile app: BUILT (all 10 screens), browser-tested for auth/home/profile/recommendation/details. See checklist.

## WAITING ON USER (do NOT block on these)
- Admission requirements per program (min SSC/HSC GPA, groups) -> backend/data/real/programs.csv columns required_groups,min_ssc_gpa,min_hsc_gpa
- Scholarship rules -> backend/data/real/scholarships.csv (template in data/templates)
- Chat documents (brochures/FAQ PDFs) -> admin POST /admin/knowledge
- LLM API key -> backend/.env LLM_API_KEY (+ LLM_PROVIDER anthropic|openai). Without key chat returns best passage + source.

## HOW TO RUN
Backend: cd backend && pip install -r requirements.txt && REAL_DATA_DIR=data/real DEV_ADMIN_EMAIL=admin@example.com DEV_ADMIN_PASSWORD=change-me-123 uvicorn app.main:app --host 0.0.0.0 --port 8000
Mobile:  cd mobile && npm install && EXPO_PUBLIC_API_URL=http://<your-computer-ip>:8000 npx expo start

## Mobile checklist
- [x] mobile: Expo SDK 58 project scaffolded, deps installed (use `npm install`, NOT `expo install`: sandbox blocks api.expo.dev; versions from node_modules/expo/bundledNativeModules.json)
- [x] mobile/src: theme, config(API_URL), storage(secure), api client (401 -> logout), i18n en/bn, auth context
- [x] backend: GET /events, POST/DELETE /admin/events, GET /meta/options (interest chips from survey)
- [x] mobile screens written + typecheck clean (`cd mobile && npx tsc --noEmit`): Login, Register, Forgot/Reset, Home, Profile(+result-sheet upload/confirm), ProfileEdit, Recommendation(+scholarships), DepartmentDetails(+report download), Chat, ParentMode(+ChildSummary), ParentAccess(student side), More/Settings/Notifications/ChangePassword/About/Help. English + Bangla.
- [x] web bundle OK (`EXPO_PUBLIC_API_URL=http://localhost:8000 npx expo export --platform web`); playwright flow register->profile->recommendation->details passed, no console errors (script was in scratchpad e2e.js)
- [x] fixed: BBA got IT tags from its majors -> tags now from program NAME only (regression test added); parent summary budget key; friendly missing-field names
- [ ] NOT yet browser/device-tested: Chat UI, Parent Mode UI, More screens, result-sheet upload UI, PDF download on a phone (code written, backend tested)
- [ ] Not built: Google sign-in (design shows it; backend has no Google auth), profile photo upload, "Admission Updates"/"Career Roadmap" as separate screens (roadmap shows inside Department Details)
- [ ] After user sends data: fill required_groups/min_ssc_gpa/min_hsc_gpa in data/real/programs.csv, scholarships.csv, upload chat docs, set LLM_API_KEY

## UI FIDELITY PASS (user wants the app to look EXACTLY like their UI/UX doc, "assignment 1")
Original screens: mobile-ui-reference/ (10 PNGs extracted from the docx, in order: login, register, forgot, home, profile, recommendation, chat, details, parent, more).
Differences to fix (tick when done):
- [x] shared art (react-native-svg): building illustration, ring gauge, logo mark, decorative circles, light/dark headers, tab bar top indicator
- [x] Login: OR divider, Continue with Google (backend has no Google auth -> button shows honest "not available yet"), DIU footer, "Student Email"
- [x] Register: Add Photo circle (backend: avatar data-URL on user), keep role chips (needed for parent)
- [x] Forgot: lock+refresh icon, "Email Address", building illustration
- [x] Home: ring gauge w/ label inside, View Details button, yellow star tile, events + See All
- [x] Profile: ring avatar, ID, "DEPT . Nth Semester" pill, settings icon, Personal Info = Email/Phone/Department/CGPA, Quick Actions; extra academic card below
- [x] Recommendation: light header, robot icon, dark card w/ building thumb, Why this, Explore More + See All w/ thumbs
- [x] Chat: robot header + Online, TODAY separator, timestamps
- [x] Details: hero illustration, bookmark, Popular pill, Key Features, Get Admission Guide, 3 career tiles
- [x] Parent Mode: dark header icon, 4-item menu card, Back to Home
- [x] More: Settings, Change Password, Language/ভাষা, About, Help, Logout(red), DIU illustration footer
- [x] rebuild web, screenshot all 10, compare side-by-side with reference

- UI fidelity pass reviewed side-by-side (reference vs app). Known small differences: building illustration is a simplified vector, no fake 9:41 status bar (real phone shows its own), mock sample numbers replaced by real data, Google sign-in shows 'not available yet', no 'Popular' badge.

## Campus & Facilities + photos (added)
- [x] Backend: GET /campus/facilities, admin POST/PUT/DELETE /admin/facilities, POST /admin/media (jpg/png/webp <=5MB -> /media/<file>), departments have `image` + `gallery`. Tests in tests/test_campus.py (58 pass).
- [x] Mobile: More > "Campus & Facilities" (category chips, photo swiper, details); Department Details shows `image` when set.
- [ ] WAITING ON USER: real DIU photos + text (hall, bus routes/timing, medical, library, labs, sports, cafeteria, clubs) and department photos. Until then screens show the building illustration.
- How to add (admin token via /auth/login): POST /admin/media with the photo -> copy `url`; POST /admin/facilities {"category":"hall","title":"...","description":"...","details":["..."],"images":["/media/x.jpg"]}; PUT /programs admin edit with "image":"/media/y.jpg".

## Scholarship / waiver rules + new Department sheet (added)
- [x] data_in/departments_v2.xlsx (new sheet: Facilities + GPA columns) -> `python3 tools/prepare_departments.py ../data_in/departments_v2.xlsx data/real/programs.csv` also writes data/real/facilities.csv (13 facilities, no photos/text yet). load_real loads facilities.
- [x] Sheet "GPA" (2.5) applied as min SSC and HSC GPA for each program (ASSUMPTION, noted in program notes). Pharmacy sheet value 8.0 is invalid -> left blank. BBA in Accounting and EEE have no GPA -> more_information_required.
- [x] services/waivers.py + GET /guidance/waivers (entry 75/50/35/25, sibling 20, CGPA 20/30/50, guardian 300000). Tests: tests/test_waivers.py (70 tests pass).
- [x] Mobile: Recommendation screen "Tuition Waivers"; Profile Edit has Golden A+ (SSC/HSC), siblings at DIU, guardian deceased.
- [ ] Waiting: application-based scholarships (rules), whether waivers combine, confirm GPA meaning + Golden-vs-A+ definition, B.Pharm GPA, required groups per program.
- [x] Owner answers: waivers do NOT combine (only one applies; API returns highest_percent). Application-based scholarships: owner will give later. Groups: Science&IT, Engineering, Health&Life = Science; Business = Commerce+Humanities; English/Law/JMC/Agriculture/Graduate/HRDI = all groups (set via FACULTY_GROUPS in tools/prepare_departments.py). Still open: B.Pharm GPA (sheet says 8.0 = invalid).

## Chat is now an LLM advisor (owner did not want rule-only feel)
- services/advisor.py builds a facts block (student profile, top matches + reasons, all programs, waivers). llm.SYSTEM is a conversational counsellor prompt (Bangla/English/Banglish). Numbers still come only from the engines; LLM explains/compares.
- Needs LLM_API_KEY. Gemini via OpenAI-compatible endpoint: LLM_PROVIDER=openai, LLM_BASE_URL=https://generativelanguage.googleapis.com/v1beta/openai, LLM_MODEL=gemini-2.5-flash. NOT tested from sandbox (Google host blocked) - test on a machine with internet.

- UI is English-only by owner request (mobile/src/i18n.tsx BANGLA_ENABLED=false; language switch hidden). Chat still understands Bangla/Banglish questions.

## Photos added (11 of 12 sent) + interactive parent report
- backend/data/real/media/*.jpg + media.csv (kind,key,file,role) -> load_real copies to uploads/media and sets program image/gallery and facility images. Mapped: ESDM, BARCH (sign + model), SWE, PESS, CIS, BBA-ACC, TE, Student Halls (2 hall signs), Labs (Data Science Lab).
- NOT used: Management "Honor Board" photo (shows students' faces/names) - add only if owner confirms.
- Parent report: tabs Cost/Study/Future/Waivers, career bottom sheet, expandable waivers, count-up/grow bars, EN/বাংলা switch (parents only; students stay English).
- Playwright tip: `text=X >> visible=true` can match hidden duplicates; click by coordinates when a tap seems to do nothing.
