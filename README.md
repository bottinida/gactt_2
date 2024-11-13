
<h1>Specialty Coffee Roasting Preference Analysis</h1>

<p>This project explores how consumer characteristics and coffee preferences influence their choice of coffee roasting levels. The analysis was conducted using a dataset collected from The Great American Taste Test, where participants shared their tasting preferences across different coffee varieties. 
  
<strong>Objective:</strong> I sought to identify patterns that might predict a consumer’s roasting preference—light, medium, or dark—based on their demographics and coffee consumption habits using machine learning techniques.</p>

<h2>Project Overview</h2>
<ul>
    <li><strong>Language Used:</strong> R</li>
    <li><strong>Models Applied:</strong> Random Forest, Boosting (GBM), Support Vector Machine (SVM - tuned and untuned), and Multinomial Logistic Regression</li>
</ul>

<h2>Methodology</h2>

<p><strong>Introduction:</strong></p>
<p>For this project, I analyzed consumer data from The Great American Taste Test event to uncover insights into roasting preferences. The objective was to create a predictive model that can suggest specific coffee roast levels for consumers based on various factors, including their coffee consumption habits, demographic details, and preference characteristics. This research offers a potential foundation for personalized recommendations in the specialty coffee market.</p>

<h3>Data Collection and Preprocessing</h3>
<p>The dataset, sourced from The Great American Taste Test, initially contained 4,042 observations with 118 variables, including demographic details and coffee tasting results. After filtering out missing values and irrelevant fields (e.g., comments), the dataset was reduced to 3,972 observations and 58 variables. The response variable, representing coffee roast preference (light, medium, dark, or no preference), was central to our analysis.</p>

<p><strong>Exploratory Data Analysis (EDA):</strong></p>
p>During the EDA phase, I used both graphical and statistical methods to uncover key relationships and insights within the data. Here are some of the highlights:</p>
<ul>
    <li><strong>Correlation Analysis</strong>: I examined the relationships between demographic factors, coffee knowledge levels, and roast preferences. Notably, expertise level and coffee origin knowledge showed a mild inverse correlation with roast preference, while the overall favorite coffee attribute correlated positively.</li>
    <li><strong>Preference Distribution</strong>: Below is the distribution of preferences for each roast level, indicating distinct consumer inclinations for light, medium, and dark roasts.</li>
</ul>

<p align="center">
    <img src="https://i.imgur.com/N9NIebt.png" height="50%" width="50%" alt="Coffee Preference Distribution"/>
    <br/>
    <span style="font-style: italic; color: gray;">Coffee Preference Distribution</span>
</p>

<h3>Methodology</h3>
<p>The data was split into training (70%) and testing (30%) sets to train and evaluate different models, including:</p>

<ul>
    <li>Random Forest: Tested with default parameters and parameter tuning to optimize <code>ntree</code> and <code>mtry</code>. The final model achieved a training error of 0% and a testing error of 18.63%.</li>
</ul>

<p align="center">
    <img src="https://i.imgur.com/IpUyzh6.png" height="50%" width="50%" alt="Best ntree according to the Min OOB Error Value"/>
    <br/>
    <span style="font-style: italic; color: gray;">Best ntree according to the Min OOB Error Value</span>
</p>


<ul>  
    <li>Boosting (GBM): Performed cross-validation with tuned parameters, yielding a testing error of 18.47%, the lowest of all models.</li>
    <li>SVM: Used both tuned and untuned configurations, with testing errors remaining at 18.89%.</li>
    <li>Multinomial Logistic Regression: Achieved an 18.89% testing error, showing competitive performance without signs of overfitting.</li>
</ul>

<p><strong>Random Forest Findings:</strong> While the Random Forest model showed a 0% training error, its testing error of 18.63% suggested potential overfitting. The model’s effectiveness varied, with <code>OverallFavCoffee</code> and <code>FrenchPress</code> emerging as top and least influential attributes, respectively.</p>

<h3>Results</h3>
<table>
    <thead>
        <tr>
            <th>Model</th>
            <th>Training Error (%)</th>
            <th>Testing Error (%)</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>Random Forest</td>
            <td>0</td>
            <td>18.63</td>
        </tr>
        <tr>
            <td>Multinomial Logistic Regression</td>
            <td>17.08</td>
            <td>18.89</td>
        </tr>
        <tr>
            <td>SVM (Untuned)</td>
            <td>18.95</td>
            <td>18.89</td>
        </tr>
        <tr>
            <td>SVM (Tuned)</td>
            <td>18.91</td>
            <td>18.89</td>
        </tr>
        <tr>
            <td>Boosting (GBM)</td>
            <td>18.37</td>
            <td><strong>18.47</strong></td>
        </tr>
    </tbody>
</table>

<p><strong>Conclusion:</strong> The Boosting model outperformed other models with a testing error of 18.47%, showing strong predictive accuracy and generalization. This suggests that Boosting may be the most effective approach for making coffee roasting preference predictions. In contrast, the Random Forest model’s performance highlighted potential overfitting, serving as a reminder of the need for balance between training accuracy and model generalizability in consumer preference modeling.</p>

</ul>

</body>
</html>
