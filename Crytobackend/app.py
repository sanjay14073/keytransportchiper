import math
from flask import Flask, jsonify, request

app = Flask(__name__)


@app.route('/encrypt', methods=['POST'])
def encrypt():
    data = request.get_json(force=True)
    message = data["message"]
    key = data["key"]
    cipherText = [""] * key
    for col in range(key):
        pointer = col
        while pointer < len(message):
            cipherText[col] += message[pointer]
            pointer += key
    encrypted_text= "".join(cipherText)
    return jsonify({"ans": encrypted_text,"key":key})


@app.route('/decrypt', methods=['POST'])
def decrypt():
    data = request.get_json(force=True)
    message= data["message"]
    key =data["key"]
    numCols = math.ceil(len(message) / key)
    numRows = key
    numShadedBoxes = (numCols * numRows) - len(message)
    plainText = [""] * numCols
    col = 0
    row = 0

    for symbol in message:
        plainText[col] += symbol
        col += 1

        if (
                (col == numCols)
                or (col == numCols - 1)
                and (row >= numRows - numShadedBoxes)
        ):
            col = 0
            row += 1

    ans="".join(plainText)
    return jsonify({"ans": ans})



if __name__ == '__main__':
    app.run(host="0.0.0.0", port=3300, debug=True)



