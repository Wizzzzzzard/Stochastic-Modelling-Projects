breed [upperclasses upperclass]
breed [middleclasses middleclass]
breed [lowerclasses lowerclass]

globals
[
  max-wage          ; maximum wage a patch can return
  min-wage          ; minimum wage a patch can return
  living-cost       ; median cost of living in UK
  median-income     ; median income in UK
  median-rent       ; median rent in UK
  max-vision
]

patches-own
[
  wage-here            ; the current amount of wages on this patch
  max-wages-here       ; the maximum amount of wages this patch can hold
]

turtles-own
[
  age              ; how old a turtle is
  wealth           ; the amount of wealth a turtle has
  life-expectancy  ; maximum age that a turtle can reach
  labour           ; amount of work a turtle does per tick
  capital          ; amount of wealth a turtle invests per tick
  tax-rate         ; amount each turtle loses to taxes
  vision           ; how many patches ahead a turtle can see
]

;;;
;;; SETUP AND HELPERS
;;;

to setup
  clear-all
  ;; set global variables to appropriate values
  set max-wage  273.97      ; highest wage for a standard worker (100,000 divided by 365)
  set min-wage  8.91	       ; minimum wage per hour (wage * labour = wealth a turtle gains per tick)
  ifelse universal-basic-income = "On"
  [ set living-cost 0 ]      ; removes living costs by using taxes
  [ set living-cost 40.945 ] ; annual living cost divided by 365
  set median-income 29900    ; set initial wealth based on percentage of this
  set median-rent 160        ; rent per week
  set max-vision 15
  set rate-of-return rate-of-return
  set growth-of-economy growth-of-economy
  ;; call other procedures to set up various parts of the world
  setup-patches
  setup-lowerclasses
  setup-middleclasses
  setup-upperclasses
  reset-ticks
end


;; set up the initial values for the middleclass variables
to setup-lowerclasses
  set-default-shape lowerclasses "person"
  create-lowerclasses (num-of-people * lower-class-population / 100)
    [ move-to one-of patches  ;; put turtles on patch centers
      set size 1.5  ;; easier to see
      set-initial-lowerclass-vars ]
end

to set-initial-lowerclass-vars
    face one-of neighbors4
    set color red
    set life-expectancy life-expectancy-min + random (life-expectancy-max - life-expectancy-min + 1)
    set vision 1 + random max-vision
    set age random life-expectancy
    set labour random 8 + random-float 4
    set wealth random 0 + random-float (0.75 * median-income)
    set capital 0
    set tax-rate lower-class-tax-rate
end

;; set up the initial values for the middleclass variables
to setup-middleclasses
  set-default-shape middleclasses "person"
  create-middleclasses (num-of-people * middle-class-population / 100)
    [ move-to one-of patches  ;; put turtles on patch centers
      set size 1.5  ;; easier to see
      set-initial-middleclass-vars ]
end

to set-initial-middleclass-vars
    face one-of neighbors4
    set color yellow
    set life-expectancy life-expectancy-min + random (life-expectancy-max - life-expectancy-min + 1)
    set vision 1 + random max-vision
    set age random life-expectancy
    set labour random 4 + random-float 4
    set wealth random (0.75 * median-income)  + random-float (1.25 * median-income)
    set capital (wealth / 4) + random-float (wealth / 2)
    set tax-rate middle-class-tax-rate
end

;; set up the initial values for the upperclass variables
to setup-upperclasses
  set-default-shape upperclasses "person"
  create-upperclasses (num-of-people * upper-class-population / 100)
    [ move-to one-of patches  ;; put upperclasses on patch centers
      set size 1.5  ;; easier to see
      set-initial-upperclass-vars ]
end

to set-initial-upperclass-vars
    face one-of neighbors4
    set color blue
    set life-expectancy life-expectancy-min + random (life-expectancy-max - life-expectancy-min + 1)
    set vision 1 + random max-vision
    set age random life-expectancy
    set labour random 4
    set wealth random (2 * median-income) + random-float (10 * median-income)
    set capital (wealth / 2) + random-float wealth
    set tax-rate upper-class-tax-rate
end

to lowerclass-move-tax-age-die  ;; lowerclasses procedure
  fd 1
  ;; lose some wealth according to taxrate
  if ticks mod 365 = 0 [    ; run check every "year"
    set wealth (wealth - ((lower-class-tax-rate / 100) * wealth)) ]
  ;; invest some money
  invest
  ;; grow older
  if ticks mod 365 = 0 [
    set age (age + 1) ]
  ;; check to see if you have children
  reproduce-lowerclasses
  ;; check for death conditions: if you have no wealth or
  ;; you're older than the life expectancy or if some random factor
  ;; holds, then you "die"
  if (wealth < 0) or (age >= life-expectancy * 365)
  [ die ]
end

to middleclass-move-tax-age-die  ;; middleclasses procedure
  fd 1
  ;; lose some wealth according to taxrate
  if ticks mod 365 = 0 [    ; run check every "year"
    set wealth (wealth - ((middle-class-tax-rate / 100) * wealth)) ]
  ;; invest some money
  invest
  ;; grow older
  if ticks mod 365 = 0 [
    set age (age + 1) ]
  ;; check to see if you have children
  reproduce-middleclasses
  ;; check for death conditions: if you have no wealth or
  ;; you're older than the life expectancy or if some random factor
  ;; holds, then you "die"
  if (wealth < 0) or (age >= life-expectancy * 365)
  [ die ]
end

to upperclass-move-tax-age-die  ;; upperclasses procedure
  fd 1
  ;; lose some wealth according to taxrate
  if ticks mod 365 = 0 [    ; run check every "year"
    set wealth (wealth - ((upper-class-tax-rate / 100) * wealth)) ]
  ;; invest some money
  invest
  ;; grow older
  if ticks mod 365 = 0 [
    set age (age + 1) ]
  ;; check to see if you have children
  reproduce-upperclasses
  ;; check for death conditions: if you have no wealth or
  ;; you're older than the life expectancy or if some random factor
  ;; holds, then you "die"
  if (wealth < 0) or (age >= life-expectancy * 365)
  [ die ]
end

to reproduce-lowerclasses  ; lowerclasses procedure
  if ticks mod 365 = 0 [    ; run check every "year"
  if random-float 100 < 25 [  ; throw "dice" to see if you will reproduce
    set wealth (wealth / 2)  ; divide wealth between parent and offspring
    face one-of neighbors4
    set color red
    set life-expectancy life-expectancy-min + random (life-expectancy-max - life-expectancy-min + 1)
    set vision 1 + random max-vision
    set age random life-expectancy
    set labour random 8 + random-float 4
    set capital 0
    set tax-rate lower-class-tax-rate
    hatch 1 [ rt random-float 360 fd 1 ]   ; hatch an offspring and move it forward 1 step
]]
end

to reproduce-middleclasses  ; middleclasses procedure
  if ticks mod 365 = 0 [    ; run check every "year"
  if random-float 100 < 25 [  ; throw "dice" to see if you will reproduce
    set wealth (wealth / 2)  ; divide wealth between parent and offspring
    set capital (capital / 2) ; divide capital between parent and offspring
    face one-of neighbors4
    set color yellow
    set life-expectancy life-expectancy-min + random (life-expectancy-max - life-expectancy-min + 1)
    set vision 1 + random max-vision
    set age random life-expectancy
    set labour random 4 + random-float 4
    set tax-rate middle-class-tax-rate
    hatch 1 [ rt random-float 360 fd 1 ]   ; hatch an offspring and move it forward 1 step
]]
end

to reproduce-upperclasses  ; upperclasses procedure
  if ticks mod 365 = 0 [    ; run check every "year"
  if random-float 100 < 25 [  ; throw "dice" to see if you will reproduce
    set wealth (wealth / 2)  ; divide wealth between parent and offspring
    set capital (capital / 2) ; divide capital between parent and offspring
    face one-of neighbors4
    set color blue
    set life-expectancy life-expectancy-min + random (life-expectancy-max - life-expectancy-min + 1)
    set vision 1 + random max-vision
    set age random life-expectancy
    set labour random 0 + random-float 4
    set tax-rate upper-class-tax-rate
    hatch 1 [ rt random-float 360 fd 1 ]   ; hatch an offspring and move it forward 1 step
  ]]
end


;; set up the initial amounts of wages each patch has
to setup-patches
  ;; give some patches the highest amount of wages possible --
  ;; these patches are the "best jobs"
  ask patches
    [ set max-wages-here 0
      if (random-float 100.0) <= percent-best-jobs
        [ set max-wages-here max-wage
          set wage-here max-wages-here ] ]
  ;; spread the wages around the window a little and put a little back
  ;; into the patches that are the "best jobs" found above
  repeat 5
    [ ask patches with [max-wages-here != 0]
        [ set wage-here max-wages-here ]
      diffuse wage-here 0.25 ]
  repeat 10
    [ diffuse wage-here 0.25 ]          ;; spread the wages around some more
  ask patches
    [ set wage-here floor wage-here     ;; round wage levels to whole numbers for simplicity
      set max-wages-here wage-here     ;; initial wage level is also maximum
      recolor-patch ]
end

to recolor-patch  ;; patch procedure -- use color to indicate wages level
  set pcolor scale-color green wage-here 0 max-wage
end

to go
  ; stop the model if there are no people left alive
  if not any? turtles [ stop ]
  if ticks > 36500 [ stop ] ;; Run simulation for 100 years

  ask turtles
    [
 turn-towards-wealth ;; choose direction holding most wealth within the turtle's vision
 set wealth wealth - living-cost ]  ;; loses money equivalent to cost of living for one day

  harvest
  ask lowerclasses
    [ lowerclass-move-tax-age-die ]
  ask middleclasses
    [ middleclass-move-tax-age-die ]
  ask upperclasses
    [ upperclass-move-tax-age-die ]

  ;; replenish wealth every wealth-growth-interval clock ticks
  if ticks mod 1 = 0
    [ ask patches [ grow-wealth ] ]
  tick

  grow-economy
end

to grow-economy
  ;; grow economy every 365 clock ticks
  if ticks mod 365 = 0
    [ set min-wage min-wage + (min-wage * (growth-of-economy / 100))
    set max-wage max-wage + (max-wage * (growth-of-economy / 100))
    set living-cost living-cost + (living-cost * (growth-of-economy / 100))]
  tick
end

to invest
  ;; return percentage of wealth as investment every 365 clock ticks
  if ticks mod 365 = 0
    [ set capital capital + (capital * (rate-of-return / 100))
      set wealth wealth + capital ]
end

;; determine the direction which is most profitable for each turtle in
;; the surrounding patches within the turtles' vision
to turn-towards-wealth  ;; turtle procedure
  set heading 0
  let best-direction 0
  let best-amount wealth-ahead
  set heading 90
  if (wealth-ahead > best-amount)
    [ set best-direction 90
      set best-amount wealth-ahead ]
  set heading 180
  if (wealth-ahead > best-amount)
    [ set best-direction 180
      set best-amount wealth-ahead ]
  set heading 270
  if (wealth-ahead > best-amount)
    [ set best-direction 270
      set best-amount wealth-ahead ]
  set heading best-direction
end

to-report wealth-ahead  ;; turtle procedure
  let total 0
  let how-far 1
  repeat vision
    [ set total total + [wage-here] of patch-ahead how-far
      set how-far how-far + 1 ]
  report total
end

to grow-wealth  ;; patch procedure
  ;; if a patch does not have it's maximum amount of wages, add
  ;; num-wages-grown to its wages amount
  if (wage-here < max-wages-here)
    [ set wage-here wage-here + random-float max-wages-here
      ;; if the new amount of grain on a patch is over its maximum
      ;; capacity, set it to its maximum
      if (wage-here > max-wages-here)
        [ set wage-here max-wages-here ]
      recolor-patch ]
end

;; each turtle harvests the grain on its patch.  if there are multiple
;; turtles on a patch, divide the grain evenly among the turtles
to harvest
  ; have turtles harvest before any turtle sets the patch to 0
  ask turtles
    [ set wealth floor (wealth + ((wage-here * labour) / count turtles-here)) ]
  ;; now that the grain has been harvested, have the turtles make the
  ;; patches which they are on have no grain
  ask turtles
    [ set wage-here 0
      recolor-patch ]
end
@#$#@#$#@
GRAPHICS-WINDOW
219
10
656
448
-1
-1
13.0
1
10
1
1
1
0
1
1
1
-16
16
-16
16
0
0
1
ticks
30.0

BUTTON
24
354
88
387
Setup
Setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
114
354
177
387
Go
Go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
18
10
190
43
num-of-people
num-of-people
2
500
500.0
1
1
NIL
HORIZONTAL

SLIDER
15
160
187
193
rate-of-return
rate-of-return
1
100
6.0
1
1
%
HORIZONTAL

SLIDER
14
197
189
230
growth-of-economy
growth-of-economy
1
100
3.0
1
1
%
HORIZONTAL

SLIDER
11
236
191
269
upper-class-tax-rate
upper-class-tax-rate
0
100
40.0
1
1
%
HORIZONTAL

SLIDER
10
274
192
307
middle-class-tax-rate
middle-class-tax-rate
0
100
25.0
1
1
%
HORIZONTAL

SLIDER
12
313
190
346
lower-class-tax-rate
lower-class-tax-rate
0
100
15.0
1
1
%
HORIZONTAL

SLIDER
8
48
200
81
upper-class-population
upper-class-population
0
100
10.0
1
1
%
HORIZONTAL

SLIDER
6
84
200
117
middle-class-population
middle-class-population
0
100
30.0
1
1
%
HORIZONTAL

SLIDER
8
122
197
155
lower-class-population
lower-class-population
0
100
60.0
1
1
%
HORIZONTAL

SLIDER
667
15
860
48
life-expectancy-min
life-expectancy-min
1
80
40.0
1
1
Years
HORIZONTAL

SLIDER
666
52
863
85
life-expectancy-max
life-expectancy-max
2
100
80.0
1
1
Years
HORIZONTAL

SLIDER
679
91
851
124
percent-best-jobs
percent-best-jobs
5
25
10.0
1
1
%
HORIZONTAL

MONITOR
678
137
773
182
Minimum Wage
min-wage
2
1
11

MONITOR
779
137
879
182
Maximum Wage
max-wage
2
1
11

PLOT
25
462
322
656
People per Class
Days
Population
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Lowerclass" 1.0 0 -2674135 true "" "plot count lowerclasses"
"Middleclass" 1.0 0 -1184463 true "" "plot count middleclasses"
"Upperclass" 1.0 0 -13345367 true "" "plot count upperclasses"

MONITOR
712
190
830
235
Daily Cost of Living
living-cost
2
1
11

PLOT
334
461
663
655
Wealth per Class
Days
Wealth
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Lowerclass" 1.0 0 -2674135 true "" "plot sum [ wealth ] of lowerclasses"
"Middleclass" 1.0 0 -1184463 true "" "plot sum [ wealth ] of middleclasses"
"Upperclass" 1.0 0 -13345367 true "" "plot sum [ wealth ] of upperclasses"

CHOOSER
691
241
840
286
universal-basic-income
universal-basic-income
"Off" "On"
1

PLOT
671
462
957
653
Class / Wealth Histogram
Class
Wealth
0.0
3.0
0.0
10.0
true
false
"set-plot-y-range 0 num-of-people" ""
PENS
"default" 1.0 1 -16777216 true "" "plot-pen-reset\nset-plot-pen-color red\nplot sum [ wealth ] of lowerclasses\nset-plot-pen-color yellow\nplot sum [ wealth ] of middleclasses\nset-plot-pen-color blue\nplot sum [ wealth ] of upperclasses"

@#$#@#$#@
## 1. Purpose
Model aims to compare the different rates at which wealth is increasing, vs the corresponding increase in income, i.e., how much money is returned by simply investing or collecting interest on pre-existing money or assets vs the equivalent amount of money that is returned from wages for work. It will also include various other factors that may affects these amounts, such as variable tax rates for each class, welfare programs alleviating costs, the rate of return on capital and the nominal economic growth rate. The idea for this model is based on the key concepts behind economist Thomas Piketty’s research in Capital in the Twenty First Century.

The model will mainly focus on the rate at which the economy grows and the percentage rate of returns for capital and income, as well as modelling expenses for an average person. Sliders are also included for different tax rates and a universal basic income option that will remove the cost of living from the equation.

The goal of the model is to represent the vast differences in earning ability between those with capital and those earning incomes. It also aims to find out if there is any combination of variables that will be able to alleviate this disparity, not by simply switching it around but by finding a way that both earning abilities can sit at roughly the same level, while also being higher than the initial income return rate.

## 2. Entities, state variables, and scales

"The entities in this model are members of three distinct classes (represented by turtles) and job alternatives (represented by patches) that vary in the wages they pay. 
The turtles have the following [state] variables:
•	their location in space (primitives xcor and ycor), 
•	their current wealth (in GBP)
•	the amount of labour they carry out a day (ranging from 0 to 12 hours based on the turtles class)
•	age - how old a turtle is in days
•	life-expectancy (the maximum age that a turtle can reach)
•	capital- this is the amount of wealth a turtle sets aside for investing per year. After investing it is then added to the turtle’s wealth
•	tax-rate- the amount each turtle loses to taxes, with a different tax rate for each class
•	vision- how many patches ahead a turtle can see, this determines how far they can travel for jobs.

The landscape is a grid of potential jobs, each of which has two static [state] variables: the current wages that the patch pays out (in the same money units) and the maximum amount of wages that this patch can hold. This landscape is 32 x 32 patches in size.

The model time-step is 1 day, and simulations run for 50 years." 


## 3. Process overview and scheduling

The model has the following actions which take place over two distinct time scales. 

The following actions take place each tick (representing a day):

The agents each turn towards the patch with the best paying job in their vision. They then approach it as quickly as possible and extract wages from it. The wages are split evenly between all the agents on the patch at the time they ‘harvest’ wages. These wages are then multiplied by the agents’ labour variable to determine the amount of wealth they make each tick. After increasing their wealth via wages, the agents are then deducted their cost of living. This is equal to the median cost of living in the UK.

After each tick the patches wages are reinitialised with a random amount of wages between the minimum and maximum wage currently available at the time. Finally at the end of each tick the model checks to see if any agents have reached their maximum life expectancy or hit a wealth of 0, at which point they die.

Additionally, the outputs, view and plots are updated with each tick.

Meanwhile the following actions occur every 365 ticks (representing a year):

The economy grows according to the value set in the growth-of-economy variable. This causes the minimum and maximum wages to increase by the same percentage as the variable, while the cost of living also increases.

The agents undergo several procedures at the end of each year:
•	Their age increases by 1
•	Each agent has a 25% chance to reproduce and create an offspring with half their wealth and capital, as well as the initial state variables of their class
•	Each agent is taxed according to their class bracket. By default, this is 15, 25 and 40% percent respectively
•	Agents from the middle and upper-class receive a return on their capital equal to the return-on-investment variable. This capital is then added to their wealth before they set aside a percentage of their new wealth to use as capital for the next cycle.

## 4. Design concepts

Basic principles: The inherent idea is based off Thomas Piketty’s thesis in Capital in the 21st Century which is as follows:

•	The ratio of wealth to income is rising in all developed countries.
•	Unless extreme measures are taken this trend will likely continue.
•	If it continues, the future will begin to resemble the 19th century, where most economic elites inherited their wealth rather than working for it.
•	His proposed best solution would be a globally coordinated effort to tax wealth.

The basic concept is that the wealth-to-income ratio and the comparison of the rate of return on capital (represented as r) to the rate of nominal economic growth (g, representing the increase in wages caused by economic growth). The rate of return on capital is a somewhat abstract idea, although an example would be as follows: If you invest £100 in an enterprise and it returns you £10 a year in income then your rate of return would be 10%. In the context of this model r is the rate of return on all investments combined. One of the main points the book asserts is that the average r is 6% regardless of the state of the economy, meaning that if g is less than 6% then the wealth of the already wealthy will grow faster than the economy as a whole. In practice g has been below 6% the past few decades, with this trend expected to continue.

Emergence: The model’s main output is the share of total wealth that each class owns, based on adjusting g and r, as well as other factors such as the taxation rates for each class, the initial amount of money each member of a class starts with and the amount they pass on to their offspring. This output changes based on the amount of wages being collected as well as the amount of money each class member can set aside for investment, with it being expected that outside of extreme scenarios the share of total money owned by the upper class will increase, albeit at different speeds.

Adaptive behaviour: The adaptive behaviour of agents is repositioning: the decision of which nearby jobs to move to (or whether to stay put), considering the wages they are currently making and the number of agents they have to split it with. Each time-step, agents can reposition to any jobs nearby (within their sensing-radius) or retain their current position.

Objective: Members of the lower and middle class seek to locate the best paying job to acquire enough wealth to afford their living costs for each tick, whilst also having enough money to pass onto their offspring to ensure both their survival. The amount of wages they receive is based on the below equation:

∆Wealth = Wages * Labour

Meanwhile members of the upper class have no such objective as the majority of their wealth comes from their inherited wealth and the annual rate of return on their wealth according to the below equation:

Wealth = Wealth + (Capital * Rate-of-Return)

As a result, the upper class’s wealth is expected to increase exponentially in comparison to that of the other classes.

Prediction: The model estimates the population and share of wealth for each class at each time step. This is possible because the rate at which their wealth increases is constant, and the chance of a given class member reproducing is also static.
Sensing: The class members are assumed to know the location of the patches with the best paying jobs, without error.

Interaction: The class members interact with each other only indirectly via competition for wages; the number of wages on a patch is divided evenly amongst the agents on a patch during each time step so it is in a agent’s interest to find a high value patch with no other agents on it. Upper class agents actively drive wages down, especially as many of them receive no new wealth from a patch due to their having a labour value of 0.

Stochasticity. The initial state of the model is stochastic: the maximum and actual wages of each job (patch), and agent locations, as well as their attributes, are set randomly. Stochasticity is thus used to simulate an environment in which class members with different amounts of initial wealth, work ability and ability to seek jobs are present. Agents have a random chance to either die or reproduce at a given time step and patches are replenished by a random amount of wages between their minimum and maximum potential every other time step.
Observation: The View shows the location of each agent on the work landscape. Graphs show population of each class at a given time step, as well as the amount of wealth each class owns and the share of the total wealth this represents.

Learning and Collectives are not part of this model. 

## 5. Initialisation

The maximum wage potential of a given patch is determined from a range between the minimum wage (£8.91) and the maximum wage available (initially this is £273.97). The wages are then spread around each patch that has the maximum wage to ensure a gradient of various wages is present.

A number of agents of each class, proportional to the percentage of the total population, are initialised and placed at random patches. They are then given random variables, within a set range for their class.

## 6. Submodels

Vision, which describes the maximum distance (or difference from) their current job that agents can detect the value of other patches and move towards them.

Agent repositioning. An agent determines whether they can achieve higher wages at a different patch to the one they are at. If they can they move towards this patch, otherwise they remain at their current patch.

Economic Activity. This event is a combination of the economic growth rate, the rate of return and the tax rates for each class. This adjusts the wealth, wages and cost of living for all agents at a regular time interval. 

## RELATED MODELS
This model is based on the Sugarscape Wealth Distribution Model included in the Netlogo Model Library 

## CREDITS AND REFERENCES
•	Piketty, Thomas, 1971-. Capital In the Twenty-First Century. Cambridge Massachusetts: The Belknap Press of Harvard University Press, 2014.
•	Li, J. and Wilensky, U. (2009). NetLogo Sugarscape 3 Wealth Distribution model. http://ccl.northwestern.edu/netlogo/models/Sugarscape3WealthDistribution. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL. 
•	The Money Advice Service (2021) Paying your own way, Available at: https://www.moneyadviceservice.org.uk/en/articles/paying-your-own-way#yearly-cost-of-living
•	OECD (2019) Under Pressure: The Squeezed Middle Class, European Union: OECD.
•	Erin Yurday (December 2020) Average Rent in the UK 2021, Available at: https://www.nimblefins.co.uk/business-insurance/landlord-insurance-uk/average-rent-uk
•	Dominic Webber and Jeena O'Neill (2020) Average household income, UK: financial year ending 2019, United Kingdom: Office for National Statistics.
•	Pascale Bourquin, Jonathan Cribb, Tom Waters and Xiaowei Xu (2019) Living standards, poverty and inequality in the UK: 2019, United Kingdom Research Institution: Institute for Fiscal Studies.
•	Railsback, S. F., & Grimm, V. (2019). Agent-Based and Individual-Based Modeling: A Practical Introduction, Second Edition. Princeton University Press.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.2.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="Comparison of Society with and without UBI (Effect on Population and Class Wealth)" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="10000"/>
    <metric>count lowerclasses</metric>
    <metric>count middleclasses</metric>
    <metric>count upperclasses</metric>
    <metric>sum [ wealth ] of lowerclasses</metric>
    <metric>sum [ wealth ] of middleclasses</metric>
    <metric>sum [ wealth ] of upperclasses</metric>
    <enumeratedValueSet variable="growth-of-economy">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="life-expectancy-max">
      <value value="80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="universal-basic-income">
      <value value="&quot;Off&quot;"/>
      <value value="&quot;On&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lower-class-population">
      <value value="60"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-of-people">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="upper-class-population">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="upper-class-tax-rate">
      <value value="40"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lower-class-tax-rate">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percent-best-jobs">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="middle-class-population">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="middle-class-tax-rate">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rate-of-return">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="life-expectancy-min">
      <value value="40"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Comparison of Tax Rates on Upper Class (With and Without UBI) (Effect on Population and Class Wealth)" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="10000"/>
    <metric>count lowerclasses</metric>
    <metric>count middleclasses</metric>
    <metric>count upperclasses</metric>
    <metric>sum [ wealth ] of lowerclasses</metric>
    <metric>sum [ wealth ] of middleclasses</metric>
    <metric>sum [ wealth ] of upperclasses</metric>
    <enumeratedValueSet variable="growth-of-economy">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="life-expectancy-max">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lower-class-population">
      <value value="60"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="universal-basic-income">
      <value value="&quot;Off&quot;"/>
      <value value="&quot;On&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-of-people">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="upper-class-population">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lower-class-tax-rate">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="upper-class-tax-rate">
      <value value="0"/>
      <value value="10"/>
      <value value="20"/>
      <value value="30"/>
      <value value="40"/>
      <value value="50"/>
      <value value="60"/>
      <value value="70"/>
      <value value="80"/>
      <value value="90"/>
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percent-best-jobs">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="middle-class-population">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="middle-class-tax-rate">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rate-of-return">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="life-expectancy-min">
      <value value="80"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Comparison of Economy Growth Rate on Population and Class Wealth" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="10000"/>
    <metric>count lowerclasses</metric>
    <metric>count middleclasses</metric>
    <metric>count upperclasses</metric>
    <metric>sum [ wealth ] of lowerclasses</metric>
    <metric>sum [ wealth ] of middleclasses</metric>
    <metric>sum [ wealth ] of upperclasses</metric>
    <enumeratedValueSet variable="growth-of-economy">
      <value value="3"/>
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="life-expectancy-max">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="universal-basic-income">
      <value value="&quot;Off&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lower-class-population">
      <value value="60"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-of-people">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="upper-class-population">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="upper-class-tax-rate">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lower-class-tax-rate">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percent-best-jobs">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="middle-class-population">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="middle-class-tax-rate">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rate-of-return">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="life-expectancy-min">
      <value value="80"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
1
@#$#@#$#@
