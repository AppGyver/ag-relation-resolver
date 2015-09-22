module.exports =
  unique: (array) ->
    output = {}
    output[array[key]] = array[key] for key in [0...array.length]
    value for key, value of output

  flatten: (array) ->
    [].concat.apply([], array)
