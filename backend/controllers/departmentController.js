const Department = require("../models/Department");

const getAllDepartments = async (req, res) => {
  try {
    const { faculty, search } = req.query;

    const filter = { isActive: true };

    if (faculty) {
      filter.faculty = faculty;
    }

    if (search) {
      filter.$or = [
        { department: { $regex: search, $options: "i" } },
        { code: { $regex: search, $options: "i" } },
        { interestTags: { $in: [search.toLowerCase()] } },
      ];
    }

    const departments = await Department.find(filter);

    res.status(200).json({
      success: true,
      count: departments.length,
      data: departments,
    });
  } catch (err) {
    res.status(500).json({
      success: false,
      message: err.message,
    });
  }
};

const getDepartmentByCode = async (req, res) => {
  try {
    const dept = await Department.findOne({
      code: req.params.code.toUpperCase(),
      isActive: true,
    });

    if (!dept) {
      return res.status(404).json({
        success: false,
        message: "Department not found",
      });
    }

    res.status(200).json({
      success: true,
      data: dept,
    });
  } catch (err) {
    res.status(500).json({
      success: false,
      message: err.message,
    });
  }
};

module.exports = {
  getAllDepartments,
  getDepartmentByCode,
};