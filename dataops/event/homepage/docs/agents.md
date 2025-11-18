# <h1black>Create </h1black><h1blue>Cortex Agents using the Agents API</h1blue>

<img src="assets/agent/ag03.png" alt="Agent demonstration" width="900">

You have now experienced out of the box agents using simple configuration using Snowflake Intelligence. Snowflake also supports the creation of custom built agents using the Agents API. Let's see how a **Cortex Agent** using Streamlit will allow users to ask questions about their data all in one place.  

If you have completed all the previous steps then this step should **just work**.





- Within **Projects>Streamlits** click on the streamlit **2_CORTEX_AGENT_SOPHISTICATED**

It leverages **Streamlit extras** which has packaged in styles to customize your app. It also allows you to choose the search service and analyst semantic model during the app configuration. The agent has configurable options for the user such as multiple chart types using **Plotly**



- Ask questions about the data that might appear in the earnings calls or analyst reports.

- Ask questions about the data that might appear in the stock data or the latest infographics.


#### <h1sub> Sample Questions</h1sub>

These questions should give answers from both **unstructured** and **structured** examples using all the datasets we covered in this lab.

```
give me a table of ratings for each analyst?

what happened in the last earnings call?

What did Morgan Stanley say about Growth?

what are the latest SNOW stock prices over time in the last 12 months?

how many marketplace listings are in the latest report?

Tell me about dynamic tables?

What did Shridhar say about revenue in the last earnings call?

shall I buy Snowflake shares?

```

If you completed the optional exercise in Cortex Analyst, this is the response you will get if you ask what transcript had the lowest sentiment:

<img src="assets/agent/ag05.png" alt="Agent response example" width="600">

Try asking the following question to get more information

**Can you give me more information about that particular earnings call**



So you should see how convenient it is to bring in both the processing of unstructured datasets and structured datasets to get one holistic view of the data subject (in this case the analysis of Snowflake) in question.


#### <h1sub> Editing the Application</h1sub>

Your role in this setup allows you to edit the application. This particular agent is quite sophisticated in terms of functionality. So you can understand the key principles of how the agent works, let's switch over to a simpler agent.

Within **Projects > Streamlit** navigate to **CORTEX_AGENT_SIMPLE**

- Press **Edit** to go into edit mode.



You will notice that the semantic model has been specified as well as the search service - which is what you created earlier.

You will notice a series of functions such as:

- **run_snowflake_query**

    This calls the built-in Agent API - and will treat the question differently depending on the context. For instance, if the answer relates to structured data, it will use the tool spec **analyst1** which will attempt to turn the question into a SQL query and will use the YAML file which you created in **Cortex Analyst**. If however, the answer can only be found from unstructured data, it will use the tools spec **cortex_search** which will then use the search service to retrieve the information. It will also retrieve up to 10 citations - these will be the chunked text which were extracted earlier on in the lab.

- **process_sse_response**

    This is about parsing the results in something readable as the original response will be a JSON payload

- **execute_cortex_complete_sql**

    This uses the LLM to attempt to create a chart based on what is in the dataset. The type of LLM is defined using the **model** variable.

- **extract_python_code**

    This is used to return the Python result (which will be a Streamlit chart) into executable code.

- **replace_chart_function**

    This uses the same variables created for the suggested chart but allows for alternative Streamlit charts.

- **def main**

    This is the initial (parent) function which is executed first and calls the other functions when appropriate. 

If you would like to make any changes to this application, you will need to **duplicate it**. This is because the Streamlit app is managed by an external application.

If you duplicate the application using the duplicate button, all files associated to the application will be copied with it.


### <h1sub> Conclusion </h1sub>

The Cortex Agent provides a unified way to query both structured and unstructured datasets, enabling users to gain insights from diverse data sources within a single application. By leveraging Streamlit’s customization capabilities and integrating Snowflake’s semantic model and search service, users can seamlessly retrieve information from earnings calls, analyst reports, stock data, and more. The built-in functions ensure efficient querying, data parsing, and visualization, making it easier to analyze financial and market trends.

### <h1sub> Resources </h1sub>

- Click [here](https://github.com/sfc-gh-boconnor/build_fsi_assistant_supporting_code_v2) to view and download the code used in this lab.

- Click [here](https://quickstarts.snowflake.com/guide/s_and_p_market_intelligence_analyze_earnings_transcripts_in_cortex_ai/index.html?utm_cta=website-workload-data-science-card-one#0) to analyze earnings call transcripts with Cortex AI


- Click [here](https://quickstarts.snowflake.com/guide/getting_started_with_cortex_agents/index.html#0) to run a quickstart on Cortex Agents







