# Line Metaphors Study

This is the study code for the paper, How Lines Create Meaning.

Please note that when run from localhost, the code is in DEBUG mode, which turns on several additional features that allow direct access to the different parts of the study and also allow users to move through the study faster than study participants would.

In addition to the study itself, the explorer (which opens by default) allows users to browse participants' responses individually as well as overlay all the responses for each unique combination of parameters (this is what Figure 3 in the paper is based on).

## Running the code

The entire application is written in Svelte and requires node.js to run.

To get started:

```bash
npm install
```

Then to run the dev server:
```
npm run dev
```

The study is now accessible at [localhost:5000](http://localhost:5000).

To package up for deployment, run from the `public` directory:
```bash
npm run build && rm -f ../../lines.zip && zip -r ../../lines.zip .
```
