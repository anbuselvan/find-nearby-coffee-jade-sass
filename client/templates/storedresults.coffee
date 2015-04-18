Template.storedResults.helpers storedResults: ->
  StoredResults.find {}
Template.storedResults.events
  'click #remove': (e) ->
    $('.chk-save').each ->
      if @checked
        id = $(this).attr('data')
        found = StoredResults.findOne(
          userId: Meteor.userId()
          pid: id)
        if found
          StoredResults.remove _id: found._id
      return
    return
  'click #exports': (e) ->
    selected = []
    $('.chk-save').each ->
      if @checked
        id = $(this).attr('data')
        selected.push id
      $(this).attr 'checked', false
      return
    if selected.length == 0
      $('#model_select').modal 'show'
      return
    Meteor.call 'downloadCSVFile', selected, true, (err, fileUrl) ->
      link = document.createElement('a')
      link.download = 'Stored Results.csv'
      link.href = fileUrl
      link.click()
      return
    return
  'click #exporta': (e) ->
    Meteor.call 'downloadCSVFile', null, true, (err, fileUrl) ->
      link = document.createElement('a')
      link.download = 'Stored Results.csv'
      link.href = fileUrl
      link.click()
      return
    return
