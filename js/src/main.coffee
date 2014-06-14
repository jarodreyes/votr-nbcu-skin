class KinetekLayout extends Backbone.Marionette.Layout
    template: '#sidebar-container'
    regions:
        sidebar: '.sidebar'
        nav: '.nav-options'

    initialize: ->
        @currentSlug = null
        @content = new KinetekContent
        @listenTo @content, 'sync', @showContent

    onRender: ->
        @content.fetch()

    showContent: ->
        @contentData = []
        _.each @content.get('feed')['entry'], (cell, idx) =>
            response = 
                place: idx
                page: cell.gsx$page.$t
                slug: cell.gsx$slug.$t
                title: cell.gsx$title.$t
                body: cell.gsx$body.$t
                image: cell.gsx$image.$t
            @contentData.push response
        console.log @contentData
        contentCollection = new Backbone.Collection @contentData

        @sidebarItems = new SidebarItems
            collection: contentCollection
        @navItems = new NavItems
            collection: contentCollection
        
        @sidebar.show @sidebarItems
        @nav.show @navItems
        $('.clubhub').fadeIn('fast')

class SidebarItemView extends Backbone.Marionette.ItemView
    template: '#sidebar-item'
    className: 'sidebar-item'
    initialize: ->
        slug = @model.get('slug')
        @$el.addClass "#{slug}"
        @id = slug
    hide: ->
        @$el.fadeOut('fast')
        console.log 'hidden'
    show: ->
        @$el.fadeIn('slow')
        console.log 'shown'

class SidebarItems extends Backbone.Marionette.CollectionView
    itemView: SidebarItemView
    className: 'weiners'

class NavItemView extends Backbone.Marionette.ItemView
    template: '#nav-item'
    events: 
        'click': 'triggerEvent'
    initialize: ->
        @$el.attr 'data-content', @model.get('slug')
    triggerEvent: (event) ->
        data = @$el.data('content')
        @trigger "do:clicked", data


class NavItems extends Backbone.Marionette.CollectionView
    itemView: NavItemView
    initialize: ->
        @on 'itemview:do:clicked', (cv, slug) ->
            @trigger "nav clicked", slug
            $('.sidebar-item').hide()
            $(".#{slug}").fadeIn('fast')
            $(".cover").removeClass('slide-in')
            $(".bg-#{slug}").addClass('slide-in')

class KinetekContent extends Backbone.Model
    url: "https://spreadsheets.google.com/feeds/list/0AmkZRXO39XOSdEZXV0hLRHlVVXRiVXFlYW5RYmt3TkE/od6/public/values?alt=json"


$(document).ready(
    ->
        lb = new KinetekLayout
            el: "#main-content"
        lb.render()
)