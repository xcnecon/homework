program define calc_accuracy
    // Declare input variables
    args pred_var actual_var threshold

    // Validate inputs
    if "`pred_var'" == "" | "`actual_var'" == "" | "`threshold'" == "" {
        display as error "Usage: calc_accuracy pred_var actual_var threshold"
        exit 198
    }

    // Create predicted class based on the threshold
    gen predicted_class = (`pred_var' >= `threshold')

    // Compare predicted class to actual values
    gen correct = (`actual_var' == predicted_class)

    // Calculate accuracy
    summarize correct, meanonly
    local accuracy = r(mean)

    // Display the accuracy
    display as text "Classification Accuracy: " as result `accuracy'

    // Clean up temporary variables
    drop predicted_class correct
end

cd "$data"
use "master_chef_test.dta", clear

drop name

// catogorize string variables
encode education, gen(educ)
encode country, gen(coun)
encode cuisinespecialty, gen(speciality)

// benchmark model
global model1 age experience knife_skills plating_aesthetics creativity challenge_win_rate judges_feedback stressmanagement social_media_following audiencepopularity signaturedishes uniqueingredients hourspracticed i.educ i.coun i.speciality

logit top_20_percent $model1
estat classification
lroc, nograph
// ll = -1091, pr2 = 0.369 auc=0.8832 ca=0.83

// lasso 
global model2 c.(age experience knife_skills plating_aesthetics creativity challenge_win_rate judges_feedback stressmanagement social_media_following audiencepopularity signaturedishes uniqueingredients hourspracticed i.educ i.coun i.speciality)##c.(age experience knife_skills plating_aesthetics creativity challenge_win_rate judges_feedback stressmanagement social_media_following audiencepopularity signaturedishes uniqueingredients hourspracticed i.educ i.coun i.speciality)

qui: lasso logit top_20_percent $model2, rseed(1) selection(cv) folds(5)
ereturn list
ereturn display
predict y_hat
roctab top_20_percent y_hat
calc_accuracy y_hat top_20_percent 0.5
display 1 - (-1086) / (-1729.5441)
// pr2=0.3721 ll=-1086 auc=0.8863 ca=0.8323

// simplistic model
global model3 age experience knife_skills plating_aesthetics creativity challenge_win_rate judges_feedback stressmanagement social_media_following audiencepopularity

logit top_20_percent $model3
estat classification
lroc, nograph
// ll = -1110, pr2=0.3582, auc=0.8777, ca=0.829