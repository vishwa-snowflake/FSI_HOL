import streamlit as st
import re
from snowflake.snowpark.context import get_active_session

def validate_email(email):
    """Basic email validation"""
    if not email:
        return True  # Email is optional
    pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    return re.match(pattern, email) is not None

def validate_name(name):
    """Basic name validation"""
    if not name or not name.strip():
        return False
    # Allow letters, spaces, hyphens, and apostrophes
    pattern = r"^[a-zA-Z\s\-']+$"
    return re.match(pattern, name.strip()) is not None

def main():
    st.set_page_config(
        page_title="My Profile", 
        page_icon="👤",
        layout="centered"
    )
    
    st.title("👤 My Profile")
    st.markdown("Update your hackathon profile information")
    
    # Important notice about marketplace access
    st.info("💡 **Important:** Add your email address to access datasets from the Snowflake Marketplace!")
    
    # Get active Snowflake session
    try:
        session = get_active_session()
        
        # Get current user profile
        profile_data = session.sql("SELECT * FROM CHANGE_MY_USER_SETTINGS.PUBLIC.MY_PROFILE").to_pandas()
        
        if not profile_data.empty:
            user_info = profile_data.iloc[0]
            
            # Display current username only
            st.subheader(f"Profile Manager for {user_info['USERNAME']}")
            
            # Profile update form
            st.markdown("### Update Your Information")
            st.info("💡 **Important:** Add your email address to access datasets from the Snowflake Marketplace!")
            
            with st.form("update_profile"):
                col1, col2 = st.columns(2)
                with col1:
                    new_first_name = st.text_input(
                        "First Name *", 
                        value=user_info['FIRST_NAME'] or "",
                        help="Your display first name (required)",
                        max_chars=50
                    )
                with col2:
                    new_last_name = st.text_input(
                        "Last Name *", 
                        value=user_info['LAST_NAME'] or "",
                        help="Your display last name (required)",
                        max_chars=50
                    )
                
                new_email = st.text_input(
                    "Email Address", 
                    value=user_info['EMAIL'] or "",
                    help="Your email address (required for Snowflake Marketplace access)",
                    max_chars=100
                )
                
                # Validation feedback - only validate email format
                validation_errors = []
                
                if new_email and not validate_email(new_email):
                    validation_errors.append("Email format is invalid")
                
                if validation_errors:
                    for error in validation_errors:
                        st.error(f"❌ {error}")
                
                submitted = st.form_submit_button(
                    "Update Profile",
                    type="primary",
                    disabled=bool(validation_errors)
                )
                
                if submitted:
                    if not new_first_name.strip() or not new_last_name.strip():
                        st.error("❌ First name and last name are required!")
                    elif validation_errors:
                        st.error("❌ Please fix the validation errors above")
                    else:
                        try:
                            # Call the stored procedure - always pass email parameter, even if empty
                            email_param = new_email.strip() if new_email else ''
                            query = f"CALL CHANGE_MY_USER_SETTINGS.PUBLIC.UPDATE_MY_PROFILE('{new_first_name.strip()}', '{new_last_name.strip()}', '{email_param}')"
                            
                            result = session.sql(query).to_pandas()
                            
                            # Check if the result has the expected column (with or without quotes)
                            if 'UPDATE_MY_PROFILE' in result.columns:
                                result_message = result.iloc[0]['UPDATE_MY_PROFILE']
                            elif '"UPDATE_MY_PROFILE"' in result.columns:
                                result_message = result.iloc[0]['"UPDATE_MY_PROFILE"']
                            else:
                                # Show the actual result for debugging
                                st.error(f"❌ Unexpected result format. Columns: {list(result.columns)}")
                                st.write("Result:", result)
                                return
                            
                            if result_message.startswith('Error'):
                                st.error(f"❌ {result_message}")
                            else:
                                st.success(f"✅ {result_message}")
                                st.balloons()
                                
                                # Refresh the page to show updated info
                                try:
                                    st.experimental_rerun()
                                except:
                                    st.success("✅ Click the button again to refresh the data")
                            
                        except Exception as e:
                            st.error(f"❌ Error updating profile: {str(e)}")
        
        else:
            st.error("❌ Could not retrieve your profile information")
            
    except Exception as e:
        st.error(f"❌ Database error: {str(e)}")
        st.info("Please ensure you're running this in Snowflake and have the necessary permissions.")
    
    # Instructions
    st.markdown("---")
    st.markdown("### 💡 How to use")
    st.markdown("""
    1. **Update your name**: Change your first and last name as displayed in the system
    2. **Add your email**: Required for accessing Snowflake Marketplace datasets
    3. **Click Update Profile**: Save your changes
    
    **Note**: You can also update your profile directly in Snowflake using SQL:
    ```sql
    CALL CHANGE_MY_USER_SETTINGS.PUBLIC.UPDATE_MY_PROFILE('FirstName', 'LastName', 'email@example.com');
    ```
    """)
    
    # Footer
    st.markdown("---")
    st.markdown(
        """
        <div style='text-align: center; color: #666;'>
            <small>🔒 Your profile information is secure and only you can modify it.</small>
        </div>
        """, 
        unsafe_allow_html=True
    )

if __name__ == "__main__":
    main()