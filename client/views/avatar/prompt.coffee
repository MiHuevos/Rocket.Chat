Template.avatarPrompt.onCreated ->
	self = this
	self.suggestions = new ReactiveVar
	self.upload = new ReactiveVar

	self.getSuggestions = ->
		self.suggestions.set undefined
		Meteor.call 'getAvatarSuggestion', (error, avatars) ->
			self.suggestions.set
				ready: true
				avatars: avatars

	self.getSuggestions()


Template.avatarPrompt.helpers
	suggestions: ->
		return Template.instance().suggestions.get()

	upload: ->
		return Template.instance().upload.get()

	username: ->
		return Meteor.user()?.username


Template.avatarPrompt.events
	'click .select-service': (e) ->
		Meteor.call 'setAvatarFromService', this.blob, this.contentType, this.service, ->
			Session.set('AvatarRandom', Date.now())

	'click .login-with-service': (event, template) ->
		loginWithService = "loginWith#{_.capitalize(this)}"

		serviceConfig = {}

		Meteor[loginWithService] serviceConfig, (error) ->
			if error?.error is 'github-no-public-email'
				alert t("github_no_public_email")
				return

			console.log error
			if error?
				toastr.error error.message
				return

			template.getSuggestions()

	'change .avatar-file-input': (event, template) ->
		e = event.originalEvent or event
		files = e.target.files
		if not files or files.length is 0
			files = e.dataTransfer?.files or []

		for blob in files
			if not /image\/.+/.test blob.type
				return

			reader = new FileReader()
			reader.readAsDataURL(blob)
			reader.onloadend = ->
				template.upload.set
					service: 'upload'
					contentType: blob.type
					blob: reader.result
