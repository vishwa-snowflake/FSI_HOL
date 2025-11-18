<style>
@import url('https://fonts.googleapis.com/css2?family=Lato:wght@400;700;900&display=swap');

/* Only target content within markdown body, not platform headers */
.md-content p,
.md-content div:not([class*="grid"]):not([style*="background"]),
.md-content dt,
.md-content dd,
.md-content li {
  font-family: Lato, -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
  font-size: 16px;
  font-weight: 400;
  color: #24323D;
}

/* Heading styles */
.md-content h2,
.md-content h3,
.md-content h4 {
  font-family: Lato, -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
  font-weight: 700;
  color: #24323D;
}

/* Custom heading styles */
h0black {
  font-size: 40px !important; 
  font-family: Lato !important;
  font-weight: 700 !important;
  color: #000000 !important;
  text-transform: uppercase !important;
}

h0blue {
  font-size: 40px !important; 
  font-family: Lato !important;
  font-weight: 700 !important;
  color: #29B5E8 !important;
  text-transform: uppercase !important;
}

h1sub {
  text-transform: uppercase !important;
  color: #29B5E8 !important; 
  font-size: 20px !important; 
  font-family: Lato !important;
  font-weight: 700 !important;
}

/* Credential box styling */
.credential-box {
  background: #F7F9FC;
  border: 1px solid #DFE1E6;
  border-radius: 4px;
  padding: 12px 16px;
  font-family: 'Monaco', 'Courier New', 'Consolas', monospace;
  font-size: 14px;
  color: #24323D;
  display: inline-block;
  min-width: 250px;
  font-weight: 500;
  letter-spacing: 0.3px;
}
</style>

# <h0black>Snowflake CORTEX AI </h0black> <h0blue> Hackathon</h0blue>

Build an AI Assistant with AISQL and Snowflake Intelligence

---

## <h1sub>Getting Started</h1sub>

Welcome **Team Leader**.

Click the **HACKATHON INSTRUCTIONS** button below for step-by-step instructions to help your complete lab tutorials and where to find hackathon ideas.

<div align="center" style="margin: 30px 0; padding: 30px 0;">
  <a href="https://app.dataops.live/{{vars.CONFIGURE_PROJECT_PATH_WITH_NAMESPACE}}/documentations/{{vars.CONFIGURE_PIPELINE_ID}}?job={{vars.CONFIGURE_PROJECT_HOMEPAGE_JOB_ID}})" target="_blank" rel="noopener noreferrer">
    <svg xmlns="http://www.w3.org/2000/svg" width="180" height="40" style="cursor: pointer;">
      <defs>
        <style>
          @import url('https://fonts.googleapis.com/css2?family=Lato:wght@900&amp;display=swap');
        </style>
      </defs>
      <rect x="0" y="0" width="180" height="40" rx="20" ry="20" fill="#29B5E8" />
      <text x="90" y="26" font-family="'Lato', Arial, sans-serif" font-size="14" font-weight="900" fill="white" text-anchor="middle" letter-spacing="0.5">
        INSTRUCTIONS
      </text>
    </svg>
  </a>
</div>

---

## <h1sub>Snowsight Access</h1sub>

**🚨 CRITICAL: Share This Snowsight URL With ALL Your Team Members**

<div style="background: linear-gradient(135deg, #29B5E8 0%, #11567F 100%); border-radius: 12px; padding: 20px; margin: 20px 0; color: white; font-family: Lato, sans-serif; border: 3px solid #29B5E8;">
  <div style="text-align: center; margin-bottom: 15px;">
    <h3 style="color: white; margin: 0; font-size: 24px; font-weight: 700;">🔗 SNOWSIGHT URL FOR YOUR ENTIRE TEAM</h3>
  </div>
  <div style="background: rgba(255,255,255,0.15); border-radius: 8px; padding: 15px; margin: 10px 0; text-align: center;">
    <div style="font-size: 20px; font-weight: 900; background: white; color: #11567F; padding: 12px; border-radius: 6px; word-break: break-all; margin: 10px 0;">
      https://{{vars.DATAOPS_SNOWFLAKE_ACCOUNT}}.snowflakecomputing.com
    </div>
  </div>
  <div style="text-align: center; font-size: 16px; font-weight: 600;">
    ⚠️ <strong>ALL TEAM MEMBERS MUST USE THIS SAME URL</strong> ⚠️
  </div>
</div>

**📋 TEAM LEADER INSTRUCTIONS:**

1. **📤 COPY & SHARE:** Copy the URL above and send it to ALL your team members via email, Slack, or your preferred communication method
2. **📌 BOOKMARK:** Tell each team member to bookmark this URL for easy access throughout the hackathon
3. **✅ VERIFY:** Ensure every team member can access the URL before starting the hackathon activities
4. **🔄 REMIND:** Periodically remind your team to use this SAME URL - different URLs will cause access issues

**� TEAM LEADER: Assign these usernames to your hackathon team members**

As the team leader, assign one username to each of your team members, then share their credentials for lab environment access:

<div class="mt-6 border-t border-gray-100">
  <dl class="divide-y space-y-2 divide-gray-100">
    <div class="px-4 py-3 grid grid-cols-4">
      <dt class="text-md/6 font-medium text-gray-900">Available Usernames</dt>
      <dd class="text-md/6 text-gray-700 col-span-3">
        <div style="display: flex; flex-wrap: wrap; gap: 8px; align-items: flex-start;">
          <div class="credential-box">HACKER1</div>
          <div class="credential-box">HACKER2</div>
          <div class="credential-box">HACKER3</div>
          <div class="credential-box">HACKER4</div>
          <div class="credential-box">HACKER5</div>
        </div>
        <p style="font-size: 12px; color: #666; margin-top: 8px; font-style: italic;">Assign one username to each team member (up to 5 participants)</p>
      </dd>
    </div>
    <div class="px-4 py-3 grid grid-cols-4">
      <dt class="text-md/6 font-medium text-gray-900">Password</dt>
      <dd class="text-md/6 text-gray-700 col-span-3">
        <div class="credential-box">sn0wf@ll</div>
        <p style="font-size: 12px; color: #666; margin-top: 4px; font-style: italic;">Share this password with all your team members</p>
      </dd>
    </div>
  </dl>
</div>

<div style="background: #f8f9fa; border: 2px solid #29B5E8; border-radius: 8px; padding: 20px; margin: 20px 0; text-align: center;">
  <div style="font-size: 18px; font-weight: bold; color: #11567F; margin-bottom: 15px;">
    🚀 Click here to access Snowsight with the URL above:
  </div>
  <a href="https://{{vars.DATAOPS_SNOWFLAKE_ACCOUNT}}.snowflakecomputing.com" target="_blank" rel="noopener noreferrer">
    <svg xmlns="http://www.w3.org/2000/svg" width="280" height="50" style="cursor: pointer;">
      <rect x="0" y="0" width="280" height="50" rx="25" ry="25" fill="#29B5E8" />
      <text x="140" y="32" font-family="'Lato', Arial, sans-serif" font-size="16" font-weight="900" fill="white" text-anchor="middle" letter-spacing="0.5">
        🔗 OPEN SNOWSIGHT NOW
      </text>
    </svg>
  </a>
  <div style="font-size: 14px; color: #666; margin-top: 10px; font-style: italic;">
    Share this button with your team members for easy access.  If you need ACCOUNTADMIN ACCESS for adding trial datasets from the market place, please log in using the following:<br> <b>USERNAME:</b> USER -  <b>password</b> sn0wf@ll
  </div>
</div>

---




## <h1sub>Snowflake Intelligence Access</h1sub>

**👥 TEAM LEADER: Your team members use the SAME credentials assigned above for Snowflake Intelligence**

Inform your team members to use their assigned hackathon credentials (same usernames and password from the Snowsight section above) and click the **SNOWFLAKE INTELLIGENCE ACCESS** button for quick access to Snowflake Intelligence:

<div style="background: #f0f8ff; border: 1px solid #29B5E8; border-radius: 6px; padding: 15px; margin: 15px 0;">
  <div style="font-size: 16px; font-weight: bold; color: #11567F; margin-bottom: 8px;">
    🔄 Use the same credentials from above:
  </div>
  <div style="font-size: 14px; color: #666;">
    • <strong>Username:</strong> The same HACKER1-5 username you assigned each team member<br>
    • <strong>Password:</strong> sn0wf@ll (same for all platforms)
  </div>
</div>

<div align="center" style="margin: 20px 0;">
  <a href="https://ai.snowflake.com/SFSEHOL/{{(vars.EVENT_SLUG + '_' + vars.EVENT_CHILD_ACCOUNT_SLUG)|replace('-', '_')}}" target="_blank" rel="noopener noreferrer">
    <svg xmlns="http://www.w3.org/2000/svg" width="320" height="40" style="cursor: pointer;">
      <rect x="0" y="0" width="320" height="40" rx="20" ry="20" fill="#29B5E8" />
      <text x="160" y="26" font-family="'Lato', Arial, sans-serif" font-size="14" font-weight="900" fill="white" text-anchor="middle" letter-spacing="0.5">
        SNOWFLAKE INTELLIGENCE ACCESS
      </text>
    </svg>
  </a>
</div>

