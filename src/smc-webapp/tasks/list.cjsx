###
List of Tasks
###

{debounce} = require('underscore')

misc = require('smc-util/misc')

{Task} = require('./task')

{React, ReactDOM, rclass, rtypes}  = require('../smc-react')

exports.TaskList = rclass
    propTypes :
        actions          : rtypes.object
        path             : rtypes.string
        project_id       : rtypes.string
        tasks            : rtypes.immutable.Map.isRequired
        visible          : rtypes.immutable.List.isRequired
        current_task_id  : rtypes.string
        local_task_state : rtypes.immutable.Map
        scroll           : rtypes.immutable.Map  # scroll position -- only used when initially mounted, so is NOT in shouldComponentUpdate below.
        style            : rtypes.object

    shouldComponentUpdate: (next) ->
        return @props.tasks            != next.tasks or \
               @props.visible          != next.visible or \
               @props.current_task_id  != next.current_task_id or \
               @props.local_task_state != next.local_task_state

    componentDidMount: ->
        if @props.scroll?
            ReactDOM.findDOMNode(@refs.main_div)?.scrollTop = @props.scroll.get('scrollTop')

    componentWillUnmount: ->
        @save_scroll_position()

    render_task: (task_id) ->
        <Task
            key              = {task_id}
            actions          = {@props.actions}
            path             = {@props.path}
            project_id       = {@props.project_id}
            task             = {@props.tasks.get(task_id)}
            is_current       = {@props.current_task_id == task_id}
            editing_due_date = {@props.local_task_state?.getIn([task_id, 'editing_due_date'])}
            editing_desc     = {@props.local_task_state?.getIn([task_id, 'editing_desc'])}
            min_desc         = {@props.local_task_state?.getIn([task_id, 'min_desc'])}
        />

    render_tasks: ->
        x = []
        @props.visible.forEach (task_id) =>
            x.push(@render_task(task_id))
        return x

    save_scroll_position: ->
        if not @props.actions?
            return
        node = ReactDOM.findDOMNode(@refs.main_div)
        if node?
            @props.actions.set_local_view_state(scroll: {scrollTop:node.scrollTop})

    render: ->
        <div style={@props.style} ref='main_div'>
            {@render_tasks()}
        </div>