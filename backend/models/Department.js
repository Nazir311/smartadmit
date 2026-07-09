const mongoose = require('mongoose');

const departmentSchema = new mongoose.Schema({
  code: { type: String, required: true, unique: true, uppercase: true, trim: true },
  name: { type: String, required: true, trim: true },
  faculty: { type: String, required: true },
  minGPA: { type: Number, required: true, min: 0, max: 5 },
  seats: { type: Number, required: true },
  tuitionPerSemester: { type: Number, required: true },
  duration: { type: String, required: true },
  description: { type: String, required: true },
  careers: [{ type: String }],
  requiredSubjects: [{ type: String }],
  admissionTestRequired: { type: Boolean, default: true },
  tags: [{ type: String, lowercase: true }],
  keywordMatch: [{ type: String, lowercase: true }],
  careerMatch: [{ type: String, lowercase: true }],
  roadmap: {
    year1: [String],
    year2: [String],
    year3: [String],
    year4: [String],
    year5: [String]
  },
  jobRoles: [{ type: String }],
  industrySectors: [{ type: String }],
  isActive: { type: Boolean, default: true }
}, { timestamps: true });

departmentSchema.index({ minGPA: 1 });
departmentSchema.index({ tags: 1 });

module.exports = mongoose.model('Department', departmentSchema);
