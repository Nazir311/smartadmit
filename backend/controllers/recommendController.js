const Department = require("../models/Department");
const { rankDepartments } = require("../services/recommendationEngine");

const getRecommendations = async (req, res) => {
  try {

    const {
      sscGpa,
      hscGpa,
      interests = [],
      careerGoal = "",
      needScholarship = false
    } = req.body;

    const departments = await Department.find({
      isActive: true
    });

    if (!departments.length) {
      return res.status(404).json({
        success: false,
        message: "No department found."
      });
    }

    const student = {
      sscGpa: Number(sscGpa),
      hscGpa: Number(hscGpa),
      interests,
      careerGoal,
      needScholarship
    };

    const recommendations = rankDepartments(
      departments,
      student
    );

    return res.status(200).json({
      success: true,
      total: recommendations.length,
      recommendations
    });

  } catch (err) {

    console.error(err);

    return res.status(500).json({
      success: false,
      message: err.message
    });

  }
};

module.exports = {
  getRecommendations
};