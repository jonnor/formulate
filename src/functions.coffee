{ Function } = require('./formulate')

generateFunctions = () ->
  fs = require 'fs'
  path = require 'path'

  code = ""
  for op in ['+', '-', '*', '/']
    f = "exports['#{op}'] = function(v, a, b) { return a#{op}b; };\n"
    code += f

  filepath = path.join __dirname, 'generated.js'
  fs.writeFileSync filepath, code, 'utf-8'

  p = path.join __dirname, 'generated.js'
  functions = {}
  exported = require p
  for op, f of exported
    func = new Function f
    func.label "#a#{op}#b"
    functions[op] = func
  return functions

functions = generateFunctions()

addDefaultFunctions = (f) ->
  min = (a, b) -> if a < b then a else b
  max = (a, b) -> if a > b then a else b
  bound = (v, lower, upper) -> return min(max(v, lower), upper)
  f['min'] = Function.create(min).label('min(#a,#b)')
  f['max'] = Function.create(max).label('max(#a,#b)')
  f['bound'] = Function.create(bound).label('bound(#a,#b,#c)')
  f['ceil'] = Function.create(Math.ceil).label('ceil(#a)')

addDefaultFunctions functions

module.exports = functions
