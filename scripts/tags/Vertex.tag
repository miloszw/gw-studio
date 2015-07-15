<vertex class="{ selected: opts.selection[0] } { status.toLowerCase() }" tabindex="1" id={ id } >
  <div class="label-div">
    <p class="label">{ label }</p>
  </div>

  <style>
  vertex {
    background-clip: padding-box;
    border: 1px solid black;
    position: absolute !important;
    display: table;
    border-radius: 15px;
  }

  vertex:focus {
    outline: none;
  }

  vertex.selected {
    border: 1px solid #21cfdf;
  }

  vertex.unverified {
    background-color: rgba(255, 163, 42, 0.85);
  }

  vertex.verified {
    background-color: rgba(20, 187, 107, 0.85);
  }

  vertex.error {
    background-color: rgba(221, 72, 72, 0.85);
  }

  .label-div {
    display: table-cell;
    vertical-align: middle;
    text-align: center;
    padding: 10px;
  }

  .label {
    margin: 0;
    display: inline-block;
    min-width: 20px;
    min-height: 10pt;
  }

  .label:hover, .label:focus {
    background-color: rgba(210, 245, 248, 0.75);
    background-clip: content-box;
    outline: none;
  }

  .label::selection {
    background-color: #00c7c0;
  }
  </style>

  var $ = require('jquery');
  var jsp = require('jsplumb');
  var Constants = require('constants/VertexConstants');

  var self = this;
  var $root;

  self.defaults = {
    label: 'New Vertex',
    status: Constants.status.UNVERIFIED,
    view: {
      width: 120,
      height: 80
    }
  };

  self.one('update', function() {
    // TODO: write custom extend func without overwrite
    // (i.e. extend self with defaults but dont overwrite)
    var merged = $.extend(true, {}, self.defaults, self);
    $.extend(true, self, merged);
  });

  self.on('mount', function() {
    $root = $(self.root);

    // Set style
    var css = {
      'height': self.view.height,
      'width': self.view.width,
      'top': self.view.centerY - (self.view.height / 2),
      'left': self.view.centerX - (self.view.width / 2)
    };
    $root.css(css);

    // Make into jsPlumb source & target
    jsPlumb.makeSource(self.root);
    jsPlumb.makeTarget(self.root);

    // Make draggable
    jsp.draggable(self.root, {
      containment: true,
      filter: ".ui-resizable-handle",
      start: function(params) {
        // Avoid setting listeners on vertices not being directly
        // dragged (i.e. dragged as part of selection but not under
        // the cursor => hence will not trigger click anyway)
        var isElementBeingDragged = params.e;
        if (!isElementBeingDragged) return;

        // Avoid resetting the selection by triggering the click
        // handler on mouseup.
        self.root.addEventListener('click', function handler(e) {
          e.stopPropagation();
          this.removeEventListener('click', handler, true);
        }, true);
      }
    });

    // Make resizable
    $root.resizable({
      resize: function(e, ui) {
        // Clear the offset and size cache of jsp and repaint the vertex.
        // This prevents endpoints from appearing at pre-resize offsets.
        jsp.revalidate(ui.element.get(0));
      }
    });

    // Make selectable on focus and on click
    $root.on('focus click', function(e) {
      // Toggle if meta key was down during the click.
      var toggle = e.type == 'click' ? e.metaKey : false;
      self.opts.onselect(self.id, toggle);
    });

    // MouseEvent multiplexing. Trigger click as usual, trigger
    // mousedown-n-drag only after the cursor has left the element.
    self.handleEvent = function(evt) {
      switch(evt.type) {
        case 'mousedown':
          // Stop propagation (i.e. triggering other handlers set by e.g. jsp)
          evt.stopPropagation();
          // Prevent setting focus (which would trigger the select handler)
          evt.preventDefault();
          self.root.addEventListener('mouseleave', self, true);
          self.root.addEventListener('mouseup', self, true);
          break;

        case 'mouseup':
          self.root.removeEventListener('mouseleave', self, true);
          self.root.removeEventListener('mouseup', self, true);
          break;

        case 'mouseleave':
          // Don't trigger when hovering over child elements, e.g. label
          if (evt.target != self.root) break;

          self.root.removeEventListener('mouseleave', self, true);
          self.root.removeEventListener('mouseup', self, true);

          // Allow the `mousedown` event to propagate
          self.root.removeEventListener('mousedown', self, true);

          // Re-trigger mousedown event
          self.root.dispatchEvent(new MouseEvent('mousedown', evt));

          // Reactivate our event multiplexer
          self.root.addEventListener('mousedown', self, true);
          break;
      }
    };
    self.root.addEventListener('mousedown', self, true);

    // Trigger `updated` to set draggable/source/resize properties and
    // revalidate to set the correct offset for dragging connections.
    setTimeout(function() {
      // Run inside setTimeout to schedule it at the end of the
      // event queue so that the DOM redrawing has a chance to
      // catch up.
      jsp.revalidate(self.root);
      self.trigger('updated');
    }, 0);
  });

  self.on('updated', function() {
    if ($root) {
      var selected = self.opts.selection[0];    // Is this vertex selected?
      var single = self.opts.selection[1] == 1; // Is it the only vertex selected?

      /**  __________________________
       *  | FUNCTION      | SELECTED |
       *  | SourceEnabled | Off      |
       *  | Draggable     | On       |
       *  | Resizable     | On       |
       *  | MouseEvent mux| Off      |
       *   --------------------------
       */

      // SourceEnabled
      jsp.setSourceEnabled(self.root, !selected);

      // Draggable
      jsp.setDraggable(self.root, selected);

      // Resizable
      $root.resizable(selected && single ? 'enable' : 'disable');
      $root.children('.ui-resizable-handle').toggle(selected && single);

      // MouseEvent mux
      var modifyEventListener = selected ? self.root.removeEventListener : self.root.addEventListener;
      modifyEventListener.call(self.root, 'mousedown', self, true);
    }
  });
</vertex>
