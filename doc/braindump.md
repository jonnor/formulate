
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

> This is one secret of the mass accessibility of spreadsheets:
> they don't require abstraction—you build a concrete working example, then tweak it.
> This differs from other programming environments — even the simplest scripting languages —
> which require you to build abstractions first and only later instantiate them.
> That is a huge cognitive hurdle
https://news.ycombinator.com/item?id=10830686

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

* Guesstimate, spreadsheet with probability distributions.
https://medium.com/guesstimate-blog/introducing-guesstimate-a-spreadsheet-for-things-that-aren-t-certain-2fa54aa9340#.x7jxtil9thttps://news.ycombinator.com/item?id=10816563
* Pancakes and Spacetime by Jake Sandlund, spreadsheet-like computation environments. [video 1](https://vimeo.com/143547307).
Nice how one can 'go up' one level from a set of cells forming a computation to reuse it. Interesting ideas on encouraging copy&paste.

# User interface

Two aspects:

* Creating a user interface around a model implemented with formulate
* User interface for creating/exploring/manipulating formulate models/programs

## Display interface

* Should be able to generate/build simple UIs for a model, aided by the declared introspection data.
* Data shoud be live, and UI allow to able to manipulate the inputs of model.
* One desirable style is interactive calculators, with inputs and output widgets.
* Another is having interactive prose with embedded data variables.
* Ease of integrating/connecting custom graphs, widgets and other interactive visualizations.
* Reflect data as being manipulated, ideally allow two-way interaction.
* Allow to transition into the programming interface (and back)

Possible relationship to Flowtrace idea of
[data visualization plugins](https://github.com/flowbased/flowtrace/blob/master/ui/notes.md#visualization-plugins).

## Programming interface

* Fundamental items: Variables, Functions.
* Should/can we use RegExps for matching variables by name?
* Should be possible to share a formulate model, via URL.
And depend on it, for use in other models and embedded in software. NPM integration?
* Should be easy to get data into, including live. Do we need a DataProvider type plugin?
* How would large sets of data be stored/represented?
Structured data in key-value store, with keynames encoding structure (Redis style)?
* Programming interface should manipulate some datastructure, which also embedded formulate can use
* Should have tests as first-level citizen. Possibly in programming-by-example style
* Should be possible to easily create derivative 'scenarios', changing some inputs of the model,
and then compare results to other scenarios.

