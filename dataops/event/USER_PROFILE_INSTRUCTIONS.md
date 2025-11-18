# How to Update Your Profile

You can now modify your own username and email address in the hackathon environment!

## Method 1: Using Streamlit App (Recommended)

Access the user-friendly Streamlit application:

1. **Navigate to the Streamlit app**: `CHANGE_MY_USER_SETTINGS.PUBLIC.PROFILE_MANAGER`
2. **View your current profile**: Your information is displayed at the top
3. **Update your details**: Fill in the form with your new information
4. **Save changes**: Click "Update Profile" to save
5. **Refresh**: Refresh the page to see your updated information

## Method 2: Using SQL Procedure

Use the `UPDATE_MY_PROFILE` procedure to update your profile information:

```sql
-- Update your first and last name
CALL CHANGE_MY_USER_SETTINGS.PUBLIC.UPDATE_MY_PROFILE('YourNewFirstName', 'YourNewLastName');

-- Update your first name, last name, and email
CALL CHANGE_MY_USER_SETTINGS.PUBLIC.UPDATE_MY_PROFILE('YourNewFirstName', 'YourNewLastName', 'your.new.email@example.com');
```

## Method 2: View Your Current Profile

Check your current profile information:

```sql
-- View your current profile
SELECT * FROM CHANGE_MY_USER_SETTINGS.PUBLIC.MY_PROFILE;
```

## What You Can Change

✅ **First Name** - Your display first name  
✅ **Last Name** - Your display last name  
✅ **Email** - Your contact email address  

## What You Cannot Change

❌ **Username** - Your login username cannot be changed  
❌ **Password** - Use the standard password reset process  
❌ **Roles** - Role assignments are managed by administrators  

## Examples

### Update just your name:
```sql
CALL UPDATE_MY_PROFILE('John', 'Smith');
```

### Update name and email:
```sql
CALL UPDATE_MY_PROFILE('Jane', 'Doe', 'jane.doe@example.com');
```

### Check your current profile:
```sql
SELECT * FROM MY_PROFILE;
```

## Important Notes

- You can only modify your own profile
- Changes take effect immediately
- Email addresses should be valid format (name@domain.com)
- Names should contain only letters, spaces, hyphens, and apostrophes
- Both first name and last name are required

## Error Messages

- **"Error: First name cannot be empty"** - You must provide a first name
- **"Error: Last name cannot be empty"** - You must provide a last name  
- **"Warning: Invalid email format, email not updated"** - Check your email format

## Need Help?

If you encounter any issues updating your profile, please contact the hackathon organizers.