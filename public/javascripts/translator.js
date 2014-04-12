(function () {

  'use strict';

  var Translator = function () {

    var translations = {};

    this.translate_title = function (word) {
      return titleize(this.translate(word));
    };

    this.translate = function (word) {
      return translations[word] || word;
    };

    this.add_translation = function (key, phrase) {
      translations[key] = phrase;
    };

    function capitalize(string) {
      return string.charAt(0).toUpperCase() + string.slice(1);
    }

    function titleize(string) {
      return string.replace(/\w\S*/g, capitalize);
    }

  };

  var translator = new Translator();

  Better.translate = translator.translate;
  Better.translate_title = translator.translate_title;
  Better.add_translation = translator.add_translation;

}());
