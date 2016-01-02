
## Inspiration

> Drag green numbers with your mouse to adjust them. (Really, do it!)
> Notice how the consequences of your adjustments are reflected immediately in the following paragraph.
> The reader can explore alternative scenarios, understand the tradeoffs involved,
> and come to an informed conclusion about whether any such proposal could be a good decision.
> 
> This is possible because the author is not just publishing words.
> The author has provided a **model** — *a set of formulas and algorithms that calculate the consequences of a given scenario*.
> Some numbers above are in blue. Click a blue number to reveal how it was calculated.
> (“It will save 61 million gallons” is a particularly meaty calculation.)
>  Notice how the model’s assumptions are clearly visible, and can even be adjusted by the reader.
http://worrydream.com/ClimateChange/#media

## Relation to metrics

It is often useful to have a model of a (software) system.
For instance with a cloud service with users,
it is useful to be able to estimate with confidence, the costs of servicing users.
And to be able to understand where costs breakdown, what drives them,
and what would happen if one would change any of these variables.

Right now the modelling is often done in a spreadsheet, like Excel or Google Docs.
Model is often made by other people than those who maintain the system being modelled,
with less knowledge about the system, but more about what a desirable model would be.
There are few to no guarantees that the system and model are in sync, both when initially developed,
or that they stay true over time. 

The canonical data source for the variables is basically always somewhere else than in the model.
For instance New Relic Insights, behind custom application APIs, or sometimes application database queries.

TODO: research best-practices for 'connecting' spreadsheet to source data.
Do people just make tool which inputs it to a dedicated location in spreadsheet?

It would be ideal if the model itself, or at least core parts of it, came from the system itself.
And that it is set up such that metrics can be looked up automatically to fill in variables.

A model with visualizations could also serve as excellent, interactive, documentation
- and possibly also as a dashboard.

# Related

* Guesstimate, spreadsheet with probability diatributions
https://medium.com/guesstimate-blog/introducing-guesstimate-a-spreadsheet-for-things-that-aren-t-certain-2fa54aa9340#.x7jxtil9thttps://news.ycombinator.com/item?id=10816563
