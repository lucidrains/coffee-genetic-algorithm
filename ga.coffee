randi = (start, end)->
  Math.floor(Math.random()*(end - start)) + start

class Gene
  constructor: (@code='')->
    @cost = 9999

  random: (length)->
    while length--
      @code += String.fromCharCode(randi(0, 255))

  mutate: (chance)->
    return if (Math.random() > chance)

    index = randi(0, @code.length)
    upOrDown = if Math.random() <= 0.5 then -1 else 1
    newChar = String.fromCharCode(@code.charCodeAt(index) + upOrDown)
    
    newString = ''
    for i in [0...@code.length]
      newString += if i==index
        newChar
      else
        @code[i]

    @code = newString

  mate: (gene)->
    pivot = Math.round(@code.length / 2) - 1

    child1 = @code.substr(0, pivot) + gene.code.substr(pivot)
    child2 = gene.code.substr(0, pivot) + @code.substr(pivot)

    return [new Gene(child1), new Gene(child2)]

  calcCost: (compareTo)->
    @cost = 0
    for i in [0...@code.length]
      @cost += Math.pow((@code.charCodeAt(i) - compareTo.charCodeAt(i)), 2)

class Population
  constructor: (@goal, @size, @elitism)->
    @generationNumber = 0
    @members = for i in [0...@size]
      gene = new Gene()
      gene.random(@goal.length)
      gene

  display: ->
    lines = process.stdout.getWindowSize()[1]
    console.log('\r\n') for i in [0...lines]

    console.log "Generation: #{@generationNumber}\n"
    for i in [0...@members.length]
      console.log "#{@members[i].code} (#{@members[i].cost})"

  random_gene: ->
    gene = new Gene()
    gene.random(@goal.length)
    gene
    
  fill: ->
    while @members.length < @size
      @mate()

  kill: ->
    num_survive = Math.floor @size * @elitism
    @sort()
    @members = @members[0...num_survive]

  sort: ->
    @members.sort (a,b)->
      a.cost - b.cost

  mate: ->
    children = @members[0].mate @members[1]
    @members = @members.concat children

  generation: ->
    for member in @members
      member.calcCost @goal

    @sort()
    @display()
    @mate()
    
    @kill()
    @fill()

    for member in @members
      member.mutate 0.5
      member.calcCost @goal
      if member.code == @goal
        @sort()
        @display()
        return true

    @generationNumber++

    setTimeout =>
      @generation()
    , 5
    
population = new Population("The cake is a lie", 20, 0.3)
population.generation()