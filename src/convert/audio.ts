import { type AudioState, FileState } from "../types"

const SAMPLE_RATE = 48000;
const PREC = 10;

const emptyContext = new OfflineAudioContext({ numberOfChannels: 1, sampleRate: SAMPLE_RATE, length: 1 });

const encodeDfpwm = (input: Float32Array): Int8Array => {
  let charge = 0;
  let strength = 0;
  let previousBit = false;

  const out = new Int8Array(Math.floor(input.length / 8));

  for (let i = 0; i < out.length; i++) {
    let thisByte = 0;

    for (let j = 0; j < 8; j++) {
      const level = Math.floor(input[i * 8 + j] * 127);

      const currentBit = level > charge || (level == charge && charge == 127);
      const target = currentBit ? 127 : -128;

      let nextCharge = charge + ((strength * (target - charge) + (1 << (PREC - 1))) >> PREC);
      if (nextCharge == charge && nextCharge != target) nextCharge += currentBit ? 1 : -1;

      const z = currentBit == previousBit ? (1 << PREC) - 1 : 0;
      let nextStrength = strength;
      if (strength != z) nextStrength += currentBit == previousBit ? 1 : -1;
      if (nextStrength < 2 << (PREC - 8)) nextStrength = 2 << (PREC - 8);

      charge = nextCharge;
      strength = nextStrength;
      previousBit = currentBit;

      thisByte = currentBit ? (thisByte >> 1) + 128 : thisByte >> 1;
    }

    out[i] = thisByte;
  }

  return out;
};

export const convertAudio = async (inputAudio: ArrayBuffer, progress: (state: AudioState) => void): Promise<ArrayBuffer> => {
  progress({ state: FileState.Decoding });

  const input = await emptyContext.decodeAudioData(inputAudio);

  const duration = input.length / input.sampleRate;

  var context = new OfflineAudioContext({
    numberOfChannels: 1,
    sampleRate: SAMPLE_RATE,
    length: Math.ceil(SAMPLE_RATE * duration),
  });

  const inputSource = context.createBufferSource();
  inputSource.buffer = input;
  inputSource.connect(context.destination);
  inputSource.start();

  progress({ state: FileState.Converting });

  const rendered = await context.startRendering();

  inputSource.stop();
  inputSource.disconnect();

  const data = rendered.getChannelData(0);
  return encodeDfpwm(data);
}
