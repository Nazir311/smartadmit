const Department = require('../models/Department');

const getAllDepartments = async (req, res) => {
  const { faculty, minGPA, search } = req.query;
  const filter = { isActive: true };
  if (faculty) filter.faculty = faculty;
  if (minGPA) filter.minGPA = { $lte: parseFloat(minGPA) };
  if (search) {
    filter.$or = [
      { name: { $regex: search, $options: 'i' } },
      { code: { $regex: search, $options: 'i' } },
      { tags: { $in: [search.toLowerCase()] } }
    ];
  }
  const departments = await Department.find(filter).sort({ minGPA: -1 });
  return res.status(200).json({ success: true, count: departments.length, data: departments });
};

const getDepartmentByCode = async (req, res) => {
  const dept = await Department.findOne({ code: req.params.code.toUpperCase(), isActive: true });
  if (!dept) return res.status(404).json({ success: false, message: 'Department not found.' });
  return res.status(200).json({ success: true, data: dept });
};

module.exports = { getAllDepartments, getDepartmentByCode };
