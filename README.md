# Trans

It contains the translation command.

- This command uses the Google Translate API.
- Enable the [Google Translate API](https://cloud.google.com/translate/) in the console of Google Cloud Platform, please get the api key.

## Usage

```
$ nim c -d:ssl trans.nim
$ echo "your api key" > ~/.trans/credential.txt
$ ./trans "Thank you." -to:ja -from:en
```
