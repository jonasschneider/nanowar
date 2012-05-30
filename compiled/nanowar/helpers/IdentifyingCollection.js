// Generated by CoffeeScript 1.3.3
(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(function(require) {
    var Backbone, IdentifyingCollection, uuid;
    Backbone = require('backbone');
    uuid = require('uuid');
    return IdentifyingCollection = (function(_super) {

      __extends(IdentifyingCollection, _super);

      function IdentifyingCollection() {
        return IdentifyingCollection.__super__.constructor.apply(this, arguments);
      }

      IdentifyingCollection.prototype._add = function(model, options) {
        model = this._prepareModel(model, options);
        if (!model.id) {
          console.log("Setting UUID");
          model.set({
            id: uuid()
          });
        }
        return IdentifyingCollection.__super__._add.call(this, model, options);
      };

      return IdentifyingCollection;

    })(Backbone.Collection);
  });

}).call(this);
