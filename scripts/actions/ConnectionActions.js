define(['app/RiotControl', 'constants/ConnectionConstants'], function(RiotControl, Constants) {

  var CALLS = Constants.calls;
  var EVENTS = Constants.events;

  return {
    // Listeners

    /**
    * Subscribes to onopen, onclosed and onmessage
    * @param {object} handlers - object with handlers
    */
    addConnectionListener: function(handlers) {
      var onopen = handlers.onopen;
      if (onopen) {
        RiotControl.on(EVENTS.CONNECTION_ESTABLISHED, function(websocket) {
          onopen(websocket);
        });
      }

      var onclose = handlers.onclose;
      if (onclose) {
        RiotControl.on(EVENTS.CONNECTION_CLOSED, function() {
          onclose();
        });
      }

      var onmessage = handlers.onmessage;
      if (onmessage) {
        RiotControl.on(EVENTS.INCOMING_MESSAGE, function(message) {
          onmessage(message);
        });
      }
    },

    // Triggers
    getWebSocket: function(callback) {
      RiotControl.trigger(CALLS.GET_WEBSOCKET, callback);
    },
    isSocketOpen: function(callback) {
      this.getWebSocket(function(websocket) {
        // !!var coerces var to boolean
        callback(!!websocket);
      });
    },
    connect: function(url, callback) {
      RiotControl.trigger(CALLS.CONNECT, url);
      // callback will receive the websocket upon connection
      if (callback) this.addConnectionListener({onopen: callback});
    },
    disconnect: function(callback) {
      RiotControl.trigger(CALLS.CLOSE);
      // callback will receive the websocket upon connection
      if (callback) this.addConnectionListener({onclose: callback});
    },
    send: function(message) {
      RiotControl.trigger(CALLS.SEND, message);
    }
  }
});
