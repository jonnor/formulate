chai = require 'chai'
formulate = require '..'
functions = require '../src/functions'

describe 'c=a+b,a=1,b=2', ->
  da = null
  it 'c should be 3', ->
    da = formulate.Computation.create('simple')
        .description 'Make things as simple as they can be, but no simpler'
        .var('a').set 1
        .var('b').set 2
        .var('c').function ['a', 'b'], (v, a, b) -> return a + b
        .parent()
    chai.expect(da.data['c']).to.eql 3

  it 'a=2 should make c=4', ->
    da.transaction 'initial', () ->
      @set 'a', 2
    chai.expect(da.data['c']).to.eql 4

describe 'guv proportional scaling', ->
  f = functions
  c = formulate.Computation.create('proportional')
    .var('N').label('jobs in queue')
    .var('p').label('processing time')
    .var('ta').label('target time')
    .var('T_w').label('waiting time').function(['N', 'p'], f['*'])
    .var('T_a').label('available time').function(['ta', 'p'], f['-'])
    .var('W').label('required workers').function(['T_w', 'T_a'], f['/'])
    .parent()
  it 'should solve for W', ->
    c.open().set('N', 100).set('p', 10).set('ta', 52).close()
    chai.expect(Math.ceil(c.data['W'])).to.equal 24
  it 'render T_w as ascii MathML symbolically', ->
    render = c.mathML 'T_w'
    chai.expect(render).to.equal 'T_w = (N*p)'

  it 'should solve for W_b', ->
    c.var('min').label('worker minimum').set 2
    c.var('max').label('worker maximum').set 12
    c.var('W_r').function(['W'], f['ceil'])
    c.var('W_b').label('workers').function(['W_r', 'max', 'min'], f['bound'])
    chai.expect(c.data['W_b']).to.equal 12

  it 'render W as ascii MathML symbolically', ->
    render = c.mathML 'W'
    chai.expect(render).to.equal 'W = ((N*p)/(ta-p))'

  it 'render W_b as ascii MathML symbolically', ->
    render = c.mathML 'W_b', true
    chai.expect(render).to.equal 'W_b = (bound((ceil(((N*p)/(ta-p)))),max,min))'

  it 'render solved W_b as ascii MathML', ->
    render = c.mathML 'W_b', false
    chai.expect(render).to.equal 'W_b = (bound((ceil(((100*10)/(52-10)))),12,2)) = 12'

  it 'should generate C code with same solution', (done) ->
    formulate.generateCProgram c, 'W_b'
    { exec } = require 'child_process'
    exec 'gcc -o prog prog.c -lm -Wall && ./prog', (err, stdout, stderr) ->
      chai.expect(err, "#{err?.message}: #{stderr}\n#{stdout}").to.not.exist
      chai.expect(stdout).to.equal "W_b=12.00\n"
      done()
