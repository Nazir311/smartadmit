const generatePDFBase64 = (profile, recommendations, parentSummaryEn) => {
  const top = recommendations[0] || {};
  const effectiveGpa = Math.min(profile.sscGpa || 0, profile.hscGpa || 0);
  const now = new Date().toLocaleDateString('en-GB', { day: '2-digit', month: 'long', year: 'numeric' });

  const roadmapRows = (roadmap) => {
    if (!roadmap) return '';
    const years = ['year1', 'year2', 'year3', 'year4'];
    return years.map((y, i) => {
      const items = (roadmap[y] || []).slice(0, 3).join(', ');
      return `<tr><td style="padding:6px 10px;border:1px solid #e2e8f0;font-weight:600;background:#f8fafc;">Year ${i + 1}</td><td style="padding:6px 10px;border:1px solid #e2e8f0;">${items || 'N/A'}</td></tr>`;
    }).join('');
  };

  const deptCards = recommendations.map((d, i) => {
    const medal = ['🥇', '🥈', '🥉'][i];
    return `
    <div style="margin-bottom:18px;padding:16px;border:2px solid ${i === 0 ? '#2563eb' : '#e2e8f0'};border-radius:10px;background:${i === 0 ? '#eff6ff' : '#fff'};">
      <h3 style="margin:0 0 6px;color:#1e3a8a;">${medal} ${d.name} (${d.code}) — <span style="color:#2563eb;">${d.confidenceScore}% Match</span></h3>
      <div style="display:flex;gap:8px;margin-bottom:10px;flex-wrap:wrap;">
        <span style="background:#dbeafe;color:#1e40af;padding:3px 8px;border-radius:6px;font-size:11px;">Academic: ${d.academicAlignment}%</span>
        <span style="background:#dcfce7;color:#166534;padding:3px 8px;border-radius:6px;font-size:11px;">Interest: ${d.interestAlignment}%</span>
        <span style="background:#fef3c7;color:#92400e;padding:3px 8px;border-radius:6px;font-size:11px;">Career: ${d.careerAlignment}%</span>
        <span style="background:#f3e8ff;color:#6b21a8;padding:3px 8px;border-radius:6px;font-size:11px;">Practical: ${d.practicalFit}%</span>
      </div>
      <ul style="margin:0 0 10px;padding-left:18px;">
        ${(d.reasoning || []).map(r => `<li style="margin-bottom:3px;font-size:13px;">${r}</li>`).join('')}
      </ul>
      <p style="margin:0 0 4px;font-size:13px;"><strong>Tuition:</strong> BDT ${(d.tuitionPerSemester || 0).toLocaleString()}/semester &nbsp;|&nbsp; <strong>Scholarship:</strong> ${d.scholarshipChance}</p>
      <p style="margin:0;font-size:13px;"><strong>Job Roles:</strong> ${(d.jobRoles || []).slice(0, 3).join(', ')}</p>
      ${i === 0 ? `<h4 style="margin:12px 0 6px;color:#1e3a8a;">4-Year Career Roadmap</h4>
      <table style="width:100%;border-collapse:collapse;font-size:12px;">${roadmapRows(d.careerRoadmap)}</table>` : ''}
    </div>`;
  }).join('');

  const html = `<!DOCTYPE html>
<html>
<head><meta charset="UTF-8"><title>SmartAdmit Report</title></head>
<body style="font-family:Arial,sans-serif;margin:0;padding:32px;color:#0f172a;max-width:800px;">
  <div style="text-align:center;margin-bottom:28px;padding-bottom:20px;border-bottom:3px solid #2563eb;">
    <h1 style="margin:0;color:#2563eb;font-size:26px;">🎓 DIU SmartAdmit</h1>
    <p style="margin:4px 0 0;color:#64748b;font-size:14px;">AI Admission & Career Guidance Report</p>
    <p style="margin:4px 0 0;color:#94a3b8;font-size:12px;">Generated: ${now}</p>
  </div>

  <div style="background:#f8fafc;border:1px solid #e2e8f0;border-radius:10px;padding:18px;margin-bottom:24px;">
    <h2 style="margin:0 0 12px;color:#1e3a8a;font-size:16px;">📋 Student Profile</h2>
    <table style="width:100%;font-size:13px;">
      <tr><td style="padding:4px 0;color:#64748b;width:160px;">Name</td><td>${profile.name || 'N/A'}</td></tr>
      <tr><td style="padding:4px 0;color:#64748b;">SSC GPA</td><td>${profile.sscGpa || 'N/A'}</td></tr>
      <tr><td style="padding:4px 0;color:#64748b;">HSC GPA</td><td>${profile.hscGpa || 'N/A'}</td></tr>
      <tr><td style="padding:4px 0;color:#64748b;">Effective GPA</td><td><strong>${effectiveGpa}</strong></td></tr>
      <tr><td style="padding:4px 0;color:#64748b;">Group</td><td>${profile.group || 'N/A'}</td></tr>
      <tr><td style="padding:4px 0;color:#64748b;">Interests</td><td>${(profile.interests || []).join(', ') || 'N/A'}</td></tr>
      <tr><td style="padding:4px 0;color:#64748b;">Career Goals</td><td>${(profile.careerGoals || []).join(', ') || 'N/A'}</td></tr>
      <tr><td style="padding:4px 0;color:#64748b;">Budget</td><td>${profile.financialConstraint || 'N/A'}</td></tr>
      <tr><td style="padding:4px 0;color:#64748b;">Scholarship Interest</td><td>${profile.scholarshipInterest ? 'Yes' : 'No'}</td></tr>
    </table>
  </div>

  <h2 style="color:#1e3a8a;font-size:16px;margin-bottom:14px;">🎯 Top 3 Department Recommendations</h2>
  ${deptCards}

  <div style="background:#f0fdf4;border:1px solid #bbf7d0;border-radius:10px;padding:18px;margin-top:24px;">
    <h2 style="margin:0 0 10px;color:#166534;font-size:15px;">👨‍👩‍👧 Parent Summary</h2>
    <pre style="font-family:Arial,sans-serif;font-size:12px;white-space:pre-wrap;line-height:1.6;margin:0;color:#0f172a;">${parentSummaryEn}</pre>
  </div>

  <div style="margin-top:32px;text-align:center;padding-top:16px;border-top:1px solid #e2e8f0;">
    <p style="color:#94a3b8;font-size:11px;margin:0;">This report was generated by DIU SmartAdmit AI System</p>
    <p style="color:#94a3b8;font-size:11px;margin:4px 0 0;">Daffodil International University — smartadmit.diu.ac.bd</p>
  </div>
</body>
</html>`;

  return Buffer.from(html).toString('base64');
};

module.exports = { generatePDFBase64 };
