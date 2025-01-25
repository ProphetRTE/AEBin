import { convertAudio } from "./audio";
import { FileState } from "../types";
const queue = [];
let running = false;
const processQueue = async () => {
    if (running)
        return;
    running = true;
    while (queue.length > 0) {
        const task = queue.shift();
        try {
            const result = await convertAudio(task.contents, task.callback);
            task.callback({ state: FileState.Finished, result });
        }
        catch (e) {
            task.callback({
                state: FileState.Error,
                message: "Error converting file",
                detail: `${e}`,
            });
        }
    }
    running = false;
};
export const convert = (contents, callback) => {
    queue.push({ contents, callback });
    processQueue();
};
export default (file, callback) => {
    file.arrayBuffer()
        .then(contents => convert(contents, callback))
        .catch(x => callback({ state: FileState.Error, message: "Failed to read file", detail: `${x}` }));
};
//# sourceMappingURL=index.js.map