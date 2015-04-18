Meteor.startup ->
  SearchResults.allow
    insert: (userId, doc) ->
      doc.userId == userId
    remove: (userId, doc) ->
      doc.userId == userId
  StoredResults.allow
    insert: (userId, doc) ->
      doc.userId == userId
    remove: (userId, doc) ->
      doc.userId == userId
  temporaryFiles.allow
    insert: (userId, file) ->
      true
    remove: (userId, file) ->
      true
    read: (userId, file) ->
      true
    write: (userId, file, fields) ->
      true
  Meteor.publish 'search_results', ->
    check @userId, String
    SearchResults.find userId: @userId
  Meteor.publish 'stored_results', ->
    check @userId, String
    StoredResults.find userId: @userId
  Meteor.methods
    clearSearchResults: ->
      currentUserId = Meteor.user()._id
      SearchResults.remove userId: currentUserId
      return
    downloadCSVFile: (ids, stored) ->
      @unblock()
      currentUserId = Meteor.user()._id
      Future = Meteor.npmRequire('fibers/future')
      FastCsv = Meteor.npmRequire('fast-csv')
      futureResponse = new Future
      fileName = Meteor.userId() + '_' + (if stored then 'stored' else 'search') + '.csv'
      filePath = './tmp/' + fileName
      searchData = []
      if ids and ids.length > 0
        if stored
          StoredResults.find(userId: currentUserId).forEach (doc) ->
            if ids.indexOf(doc.pid) != -1
              row =
                Name: doc.name
                Address: doc.address
                City: doc.city
              searchData.push row
            return
        else
          SearchResults.find(userId: currentUserId).forEach (doc) ->
            if ids.indexOf(doc.pid) != -1
              row =
                Name: doc.name
                Address: doc.address
                City: doc.city
              searchData.push row
            return
      else
        if stored
          StoredResults.find(userId: currentUserId).forEach (doc) ->
            row =
              Name: doc.name
              Address: doc.address
              City: doc.city
            searchData.push row
            return
        else
          SearchResults.find(userId: currentUserId).forEach (doc) ->
            row =
              Name: doc.name
              Address: doc.address
              City: doc.city
            searchData.push row
            return
      mkdirp 'tmp', Meteor.bindEnvironment((err) ->
        if err
          console.log 'Error creating tmp dir', err
          futureResponse.throw err
        else
          writeCsv = new Future
          FastCsv.writeToPath(filePath, searchData, headers: true).on 'finish', ->
            writeCsv.return 'done'
            return
          writeCsv.wait()
          temporaryFiles.importFile filePath, {
            filename: fileName
            contentType: 'application/octet-stream'
          }, (err, file) ->
            if err
              console.log err
              futureResponse.throw err
            else
              fileUrl = Meteor.absoluteUrl("#{temporaryFiles.baseURL}/#{file._id}")
              console.log fileUrl
              futureResponse.return fileUrl
            return
        return
      )
      futureResponse.wait()
  return
