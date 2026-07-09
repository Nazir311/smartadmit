const FAQ = require('../models/FAQ');

const getAllFAQs = async (req, res) => {
  const { category, search } = req.query;
  const filter = { isActive: true };
  if (category) filter.category = category;
  if (search) {
    filter.$or = [
      { question: { $regex: search, $options: 'i' } },
      { keywords: { $in: [search.toLowerCase()] } }
    ];
  }
  const faqs = await FAQ.find(filter).sort({ views: -1 });
  return res.status(200).json({ success: true, count: faqs.length, data: faqs });
};

const getCategories = async (req, res) => {
  const categories = await FAQ.distinct('category', { isActive: true });
  return res.status(200).json({ success: true, data: categories });
};

module.exports = { getAllFAQs, getCategories };
