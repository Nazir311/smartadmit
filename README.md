# DIU SmartAdmit

AI-powered admission and career guidance (guidance only, never an official decision).

## Backend (FastAPI) - `backend/`
```bash
cd backend && pip install -r requirements.txt
cp .env.example .env            # set JWT_SECRET, MONGODB_URI (optional), LLM_API_KEY (optional)
REAL_DATA_DIR=data/real DEV_ADMIN_EMAIL=admin@example.com DEV_ADMIN_PASSWORD=change-me-123 \
  uvicorn app.main:app --reload   # API docs at http://localhost:8000/docs
pytest                           # 50 tests
```
Without `MONGODB_URI` an in-memory database is used (data resets on restart). Without `LLM_API_KEY` the chat returns the best matching passage with its source instead of a generated answer.

## Your data
| Step | Command |
|---|---|
| Departments sheet -> programs CSV | `python tools/prepare_departments.py ../data_in/departments.xlsx data/real/programs.csv` |
| Student survey -> anonymised CSV | `python tools/prepare_students.py ../data_in/students.xlsx data/real/students_anonymized.csv` |
| Evaluate a model on the survey | `python tools/experiment.py data/real/students_anonymized.csv` |
| Add documents to the chat | admin `POST /admin/knowledge` (PDF/DOCX/TXT) |
Raw files in `data_in/` contain names and emails: do not publish or commit them.

## Still needed from you
Admission requirements (min SSC/HSC GPA, accepted groups) per program, scholarship rules, and documents for the chat (brochures, FAQs). Until then eligibility reports "more information required".
