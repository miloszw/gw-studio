<studio-canvas>
  <vertex each={ vertex, i in vertices } options={ parent.mergeVertexOptions(vertex) } />

  var $             = require('jquery');
  var RiotControl   = require('app/RiotControl');
  var VertexActions = require('action/VertexActions');

  var self = this

  self.vertices = []

  self.defaults = {
    bg: "#FFFFFF"
  };
  self.settings = $.extend({}, self.defaults, self.opts.options);

  mergeVertexOptions(vertexObject) {
    return $.extend(true, {}, self.opts.options.vertex, vertexObject);
  }

  addVertex(e) {
    // Prepare vertex object
    var vertex = {
      view: {
        centerY: e.pageY - self.root.offsetTop,
        centerX: e.pageX - self.root.offsetLeft
      }
    }
    // Dispatch action
    VertexActions.addVertex(vertex);
  }

  VertexActions.addChangeListener(function(vertices) {
    self.vertices = vertices
    self.update()
  })

  self.on('mount', function() {
    // Load vertices from model store. `getAll` will make the registered stores emit a change event,
    // together with a list of vertex objects, which in turn will trigger the change listener above.
    VertexActions.getAll()

    // Set up event listeners
    $(self.root)
      // Add new vertices on double click
      .on("dblclick", function(e) {
        if (e.target === this) self.addVertex(e);
      });

  });
</studio-canvas>
