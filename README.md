# Thesis-code-BL-SP500

This code is the how the results from the thesis "title" where achieved.

The two data thats needed to run is one stocks "csv" file from yahoo finance that contains the 
date interval for the rest of the data adjusting the code to function for other date inputs 
shouldn't be difficult though. The second is the Prices matrix you want to analyse, I included
the datasets so you know what they should look like.

A small run down of the code goes,
* data colleting first.
* adjusting prices and then using the function "benford_extract" by
  https://github.com/TommasoBelluzzo/BenfordLaw to find the distributions of both prices and log returns.
* A plot of the distribution against uniform and benfords expected distibution for comparison.
* Chi-square goodness of fit test on the data against benford and uniform.
* Using benford_extract again to find the day-by-day distributions.
* Finding the amount of days that accept the two null hypotheseses and sorting the rejected
  days to see how many days where consecutively rejected.
* Finally plotting the most and least accepted day and showing in a scatterplot 
  all days and how they accept or reject the null.
  
  # Note:
  The data is expected to reject the null this is due to the large sample as the chi-square
  goodness-of-fit test exponentiates tiny differences between the two datasets being compared
  the important result from this test is the level of conformity to benford is far greater 
  than that to the uniform distribution which is why we say the data follows Benford's Law.
