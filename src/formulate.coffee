
# A formulate computation is akin to a spreadsheet
# - contains of a set of cells containing data
# - cells data have a particular type
# - cell value can be calculated as an expression of other cells
# - when a cell changes
# 
# Unlike conventional spreadsheet implementations
# - cells can have any name
# - there is no particular order/arrangement of cells
# - the cells are arranged sparsely
# - The metadata, including type info, value constraints are stored separately from the data
# - cell changes are grouped into transactions. TODO: or make resolution fully lazy?
#
# Goals: introspectable handling of equations in 'real application'
# - explains well how the problem is modelled
# - can quickly&easily be visualized and manipulated in UI, both statically and live
# - usable by non-tech audiences with live data coming from live production systems
#
# TODO: use in http://github.com/the-grid/guv ?
# TODO: add some sort of selectors, including multi-value/ranges
# TODO: evalluate MathJS, including function DSL and units support
# TODO: allow integration into NoFlo, as component/subgraph
# TODO: add some UI prototypes
# XXX: optional integration with WebWorker?
debug = () ->
debug = console.log

addChainedAttributeAccessor = (obj, propertyAttr, attr) ->
    obj[attr] = (newValues...) ->
        if newValues.length == 0
            obj[propertyAttr][attr]
        else
            obj[propertyAttr][attr] = newValues[0]
            obj

# Holds information about a variable. Not the data itself!
class Variable
  constructor: (@ctx, @id) ->
    @properties =
      type: 'number'
      label: @id
      unit: ''
      description: ''

    for attr of @properties
      addChainedAttributeAccessor(this, 'properties', attr)

  # Chain up to parent
  set: (value) ->
    @ctx.set @id, value
    return this

  # Context modifiers
  parent: () ->
    return @ctx
  var: (name) ->
    return @ctx.var name
  function: (inputs, func) ->
    return @ctx.function @id, inputs, func

class Function
  constructor: (@func, @ctx) ->
    @properties =
      label: ''
      description: @func.toString()

    for attr of @properties
      addChainedAttributeAccessor this, 'properties', attr

  # Context modifiers
  parent: () ->
    return @ctx
  var: (name) ->
    return @ctx.var name
  function: (inputs, func) ->
    return @ctx.function @id, inputs, func

Function.create = (f) ->
  return new Function f

# A context which computations can be done in
# Holds multiple Variable and Function
class Computation
  constructor: (@id) ->
  
    # metadata
    @id = '' if not @id
    @properties =
      description: ''

    for attr of @properties
      addChainedAttributeAccessor this, 'properties', attr

    # variables
    @variables = {} # varname -> Variable
    # expressions
    @dependencies = {} # 
    @functions = {} # targetvarname -> Function
    # transaction state
    @data = {}
    @dirty = [] # { var: , value:  }
    @_currentTransaction = null

  # transactions
  open: (name) ->
    debug 'Computation.open', name
    throw new Error "open(): Already open transaction: #{name}" if @_currentTransaction
    name = 'anonymous' if not name
    @_currentTransaction = name
    return this

  close: (name) ->
    debug 'Computation.close', name
    throw new Error "close(): No open transaction" if not @_currentTransaction
    @_resolve()
    @_currentTransaction = null
    return this

  transaction: (name, func) ->
    if not name
      func = name

    @open name
    func.apply this, []
    @close name
    return this

  _implicitTransaction: (name, func) ->
    if not @_currentTransaction
      @transaction name, func
    else
      func.apply this

  # variables
  var: (name) ->
    @variables[name] = new Variable this, name if not @variables[name]
    return @variables[name]
  
  set: (name, value) ->
    @_implicitTransaction "#{name}=#{value}", () =>
      @dirty.push
        var: name
        value: value
    return this

  # functions
  function: (target, inputs, func) ->
    func = new Function(func, this) if typeof func == 'function'
    func.ctx = this
    func.inputs = inputs # hack
    @_implicitTransaction "#{target}=f(#{inputs.join(',')})", () =>
      for input in inputs
        @dependencies[input] = [] if not @dependencies[input]
        @dependencies[input].push target
        @dirty.push
          var: input
      @functions[target] = func
    return func

  # computation
  _resolve: () ->
    # TODO: respect data restrictions on the cell. agree Contract?
    # XXX: allow iterative solving, with progress?

    debug 'starting with', @data
    changes = {}
    for c in @dirty
      changes[c.var] = c.value if @data[c.var] != c.value
      @data[c.var] = c.value if c.value?
    @dirty = []
    changes = Object.keys changes
    debug 'changes in transaction', changes

    # TODO: filter out duplicate dependency changes
    for v in changes
      dependants = @dependencies[v]
      continue if not dependants
      for d in dependants
        debug "calculating #{d}", dependants, Object.keys(@functions)
        f = @functions[d]
        args = f.inputs.map((i) => @data[i])
        args.unshift args.slice()
        debug "from #{f.inputs}", args
        res = f.func.apply this, args
        debug 'got result', res
        @data[d] = res
        @dirty.push
          var: d

    @_resolve() if @dirty.length

  mathML: (target, symbolic = true) ->
    return renderAsciiMathML this, target, symbolic

  toString: () ->
    str = "#{@id}: #{@properties.description}\n\n"
    indent = '\t'
    for name, v of @variables
      func = @functions[name]
      str += "#{indent}#{name}"
      if func
        str += ": #{v.properties.label}" if v.properties.label != name
        formula = innerAsciiMathML this, name, true
        str += " = #{formula}"
      else
        str += ": #{v.properties.label}" if v.properties.label != name
      str += '\n'
    return str

Computation.create = (id) ->
  return new Computation id


innerAsciiMathML = (comp, target, symbolic = true) ->
  variable = comp.variables[target]
  func = comp.functions[target]
  data = comp.data[target]
  
  if func
    label = func.properties.label
    markers = ['#a', '#b', '#c'] # HACK
    func.inputs.forEach (input, idx) ->
      marker = markers[idx]
      rep = innerAsciiMathML comp, input, symbolic
      label = label.replace(marker, rep)
    # TODO: don't put () if a function
    return "(#{label})"
  else if symbolic
    return target
  else
    return "#{data}"

  return out
  
renderAsciiMathML = (comp, target, symbolic=true) ->
  t = innerAsciiMathML comp, target, symbolic
  out = "#{target} = #{t}"
  data = comp.data[target]
  out += " = #{data}" if not symbolic
  return out

# TODO: move out to separate file
# TODO: allow to generate a function, with free variables as arguments
generateCProgram = (comp, target) ->
  fs = require 'fs'

  variables = []
  for n, v of comp.variables
    data = comp.data[n]
    variables.push "\tfloat #{n} = #{data};\n"
  variables = variables.join ''

  equation = renderAsciiMathML comp, target, true # HACK

  body = ""
  body += variables
  body += '\t'+equation+';\n'
  body += "\tprintf(\"#{target}=%.2f\\n\", #{target});"

  prog = """
  #include <math.h>
  #include <stdio.h>
  #include "functions.c"

  int main() {

    #{body}

    return 0;
  }

  """
  fs.writeFileSync('prog.c', prog, 'utf-8')
  return prog


exports.Function = Function
exports.Variable = Variable
exports.Computation = Computation
exports.generateCProgram = generateCProgram
