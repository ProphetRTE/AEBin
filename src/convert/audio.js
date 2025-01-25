"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __generator = (this && this.__generator) || function (thisArg, body) {
    var _ = { label: 0, sent: function() { if (t[0] & 1) throw t[1]; return t[1]; }, trys: [], ops: [] }, f, y, t, g = Object.create((typeof Iterator === "function" ? Iterator : Object).prototype);
    return g.next = verb(0), g["throw"] = verb(1), g["return"] = verb(2), typeof Symbol === "function" && (g[Symbol.iterator] = function() { return this; }), g;
    function verb(n) { return function (v) { return step([n, v]); }; }
    function step(op) {
        if (f) throw new TypeError("Generator is already executing.");
        while (g && (g = 0, op[0] && (_ = 0)), _) try {
            if (f = 1, y && (t = op[0] & 2 ? y["return"] : op[0] ? y["throw"] || ((t = y["return"]) && t.call(y), 0) : y.next) && !(t = t.call(y, op[1])).done) return t;
            if (y = 0, t) op = [op[0] & 2, t.value];
            switch (op[0]) {
                case 0: case 1: t = op; break;
                case 4: _.label++; return { value: op[1], done: false };
                case 5: _.label++; y = op[1]; op = [0]; continue;
                case 7: op = _.ops.pop(); _.trys.pop(); continue;
                default:
                    if (!(t = _.trys, t = t.length > 0 && t[t.length - 1]) && (op[0] === 6 || op[0] === 2)) { _ = 0; continue; }
                    if (op[0] === 3 && (!t || (op[1] > t[0] && op[1] < t[3]))) { _.label = op[1]; break; }
                    if (op[0] === 6 && _.label < t[1]) { _.label = t[1]; t = op; break; }
                    if (t && _.label < t[2]) { _.label = t[2]; _.ops.push(op); break; }
                    if (t[2]) _.ops.pop();
                    _.trys.pop(); continue;
            }
            op = body.call(thisArg, _);
        } catch (e) { op = [6, e]; y = 0; } finally { f = t = 0; }
        if (op[0] & 5) throw op[1]; return { value: op[0] ? op[1] : void 0, done: true };
    }
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.convertAudio = void 0;
var SAMPLE_RATE = 48000;
var PREC = 10;
var emptyContext = new OfflineAudioContext({ numberOfChannels: 1, sampleRate: SAMPLE_RATE, length: 1 });
var encodeDfpwm = function (input) {
    var charge = 0;
    var strength = 0;
    var previousBit = false;
    var out = new Int8Array(Math.floor(input.length / 8));
    for (var i = 0; i < out.length; i++) {
        var thisByte = 0;
        for (var j = 0; j < 8; j++) {
            var level = Math.floor(input[i * 8 + j] * 127);
            var currentBit = level > charge || (level == charge && charge == 127);
            var target = currentBit ? 127 : -128;
            var nextCharge = charge + ((strength * (target - charge) + (1 << (PREC - 1))) >> PREC);
            if (nextCharge == charge && nextCharge != target)
                nextCharge += currentBit ? 1 : -1;
            var z = currentBit == previousBit ? (1 << PREC) - 1 : 0;
            var nextStrength = strength;
            if (strength != z)
                nextStrength += currentBit == previousBit ? 1 : -1;
            if (nextStrength < 2 << (PREC - 8))
                nextStrength = 2 << (PREC - 8);
            charge = nextCharge;
            strength = nextStrength;
            previousBit = currentBit;
            thisByte = currentBit ? (thisByte >> 1) + 128 : thisByte >> 1;
        }
        out[i] = thisByte;
    }
    return out;
};
var convertAudio = function (inputAudio, progress) { return __awaiter(void 0, void 0, void 0, function () {
    var input, duration, context, inputSource, rendered, data;
    return __generator(this, function (_a) {
        switch (_a.label) {
            case 0:
                progress({ state: "Decoding" /* FileState.Decoding */ });
                return [4 /*yield*/, emptyContext.decodeAudioData(inputAudio)];
            case 1:
                input = _a.sent();
                duration = input.length / input.sampleRate;
                context = new OfflineAudioContext({
                    numberOfChannels: 1,
                    sampleRate: SAMPLE_RATE,
                    length: Math.ceil(SAMPLE_RATE * duration),
                });
                inputSource = context.createBufferSource();
                inputSource.buffer = input;
                inputSource.connect(context.destination);
                inputSource.start();
                progress({ state: "Converting" /* FileState.Converting */ });
                return [4 /*yield*/, context.startRendering()];
            case 2:
                rendered = _a.sent();
                inputSource.stop();
                inputSource.disconnect();
                data = rendered.getChannelData(0);
                return [2 /*return*/, encodeDfpwm(data)];
        }
    });
}); };
exports.convertAudio = convertAudio;
