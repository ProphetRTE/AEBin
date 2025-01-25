"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.toSI = exports.save = exports.classNames = void 0;
/**
 * Small helper-function for building class names.
 *
 * This is especially useful when some classes should be conditionally appled, as you can write:
 * {@code classNames(f(x) ? "some-class" : undefined)}
 */
var classNames = function () {
    var classes = [];
    for (var _i = 0; _i < arguments.length; _i++) {
        classes[_i] = arguments[_i];
    }
    return classes.filter(function (x) { return !!x; }).join(" ");
};
exports.classNames = classNames;
/**
 * Save a blob to a file.
 */
var save = function (filename, blob) {
    // Somewhat inspired by https://github.com/eligrey/FileSaver.js/blob/master/src/FileSaver.js
    // Goodness knows how well this works on non-modern browsers.
    var element = document.createElement("a");
    var url = URL.createObjectURL(blob);
    element.download = filename;
    element.rel = "noopener";
    element.href = url;
    setTimeout(function () { return URL.revokeObjectURL(url); }, 60e3);
    setTimeout(function () {
        element.dispatchEvent(new MouseEvent("click"));
    }, 0);
};
exports.save = save;
/** Convert a value to a SI-suffixed number.  */
var toSI = function (size) {
    if (size >= 1024 * 1024)
        return "".concat((size / (1024 * 1024)).toFixed(2), " MiB");
    if (size >= 1024)
        return "".concat((size / 1024).toFixed(2), " KiB");
    return "".concat(size, " B");
};
exports.toSI = toSI;
