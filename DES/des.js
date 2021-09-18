function generateKey() {

  var result = "";
  var characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
  var charactersLength = 8;
  for (var i = 0; i < charactersLength; i++) result += characters.charAt(Math.floor(Math.random() * characters.length));

  document.getElementById('key').value = result;

  return result;
}

function stringToBits(inputStream) {
  result = "";
  for (var i = 0; i < inputStream.length; i++) {
      essa = inputStream[i].charCodeAt(0).toString(2);
      result += essa.padStart(8, '0');
  }
  return result;
}

function binToHex(binaryTxt) {
  var result = "";
  var temp = "";
  var counter = 0;
  for (var i = 0; i < binaryTxt.length; i++) {
      temp += binaryTxt[i];
      counter++;

      if (counter == 4) {
          result += (parseInt(temp, 2).toString(16).toUpperCase());
          counter = 0;
          temp = "";
      }
  }

  return result;
}

//returning array of 16 keys that we use in each round
function keyProcessing() {

  var keys = new Array();
  var inputKey = stringToBits(document.getElementById('key').value);

  var keyAfterPC1 = "";
  for (var i = 0; i < 56; i++) {
      keyAfterPC1 += inputKey[PC1[i] - 1];
  }

  var leftKey = keyAfterPC1.substr(0, 28);
  var rightKey = keyAfterPC1.substr(28, 28);

  for (var round = 0; round < 16; round++) {

      if (round == 0 || round == 1 || round == 8 || round == 15) {
          // shifting leftKey and rightKey 1 bit to the left
          leftKey = shiftLeftOne(leftKey);
          rightKey = shiftLeftOne(rightKey);
      } else {
          // shifting leftKey and rightKey 2 bits to the left
          leftKey = shiftLeftTwo(leftKey);
          rightKey = shiftLeftTwo(rightKey);
      }

      //split and pc2
      var keyBeforePC2 = leftKey + rightKey;
      var keyAfterPC2 = ""; //final key for one round

      for (var i = 0; i < 48; i++) {
          keyAfterPC2 += keyBeforePC2[PC2[i] - 1];
      }

      keys[round] = keyAfterPC2;
  }
  return keys;
}

function shiftLeftOne(key) {
  var temp = "";

  for (var i = 1; i < 28; i++) {
      temp += key[i];
  }

  temp += key[0];

  return temp;
}

function shiftLeftTwo(key) {
  var temp = "";

  for (var i = 0; i < 2; i++) {
      for (var j = 1; j < 28; j++) temp += key[j];
      temp += key[0];
      key = temp;
      temp = "";
  }

  return key;
}

function encrypt() {

  var inputStream = document.getElementById('inputStream').value;

  var keys = keyProcessing();

  var howManyBlocks = 0; //how many 64bits blocks input data we have

  var arrayOf64Blocks = new Array();

  var inputBitsString = stringToBits(inputStream);

  //if user type less than 8 characters (less than 64 bits)
  if (inputBitsString.length <= 64) {
      inputBitsString = inputBitsString.padEnd(64, '0');
      arrayOf64Blocks[0] = inputBitsString;
      howManyBlocks = 1;
  }

  //counting how many blocks we have
  if (inputBitsString.length > 64) {
      howManyBlocks = Math.ceil(inputBitsString.length / 64)
  }

  //throwing splitted date into 64bits block array
  var index = 0;
  for (var i = 0; i < howManyBlocks; i++) {
      var temp = "";
      var counter = 0;
      while (counter < 64 && index < inputBitsString.length) {
          temp += inputBitsString[index];
          index++;
          counter++;
      }
      arrayOf64Blocks[i] = temp;
  }

  //padding every blocks in order to have 64bits in every index of array
  if (inputBitsString.length > 64) {
      for (var i = 0; i < howManyBlocks; i++) {
          if (arrayOf64Blocks[i].length < 64) {
              arrayOf64Blocks[i] = arrayOf64Blocks[i].padEnd(64, '0');
          }
      }
  }

  //now we have splitted input data blocks in arrayOf64Blocks

  //now we do encryption on each 64 bits input blocks 

  var encryptedText = ""; //bits
  for (var blockNumber = 0; blockNumber < howManyBlocks; blockNumber++) {

      var currentData = arrayOf64Blocks[blockNumber];

      var dataAfterIP = "";
      for (var i = 0; i < 64; i++) {
          dataAfterIP += currentData[INITIAL_PERMUTATION[i] - 1];
      }

      var leftData = dataAfterIP.substr(0, 32);
      var rightData = dataAfterIP.substr(32, 32);

      for (var round = 0; round < 16; round++) {
          var after_f = f_function(rightData, keys[round]);

          var xorWithLeft = xor(after_f, leftData);

          var temp = rightData;
          rightData = xorWithLeft;
          leftData = temp;

          if (round == 15) {
              var temp = rightData;
              rightData = leftData;
              leftData = temp;
          }
      }

      var dataAfterRounds = leftData + rightData;

      var dataAfterInversedPermutation = "";
      for (var i = 0; i < 64; i++) {
          dataAfterInversedPermutation += dataAfterRounds[INVERSE_PERMUTATION[i] - 1];
      }

      encryptedText += dataAfterInversedPermutation;

  }

  //preparing output data to pass to textarea
  var hexEncryptedText = binToHex(encryptedText); //hex

  var partsBin = encryptedText.match(/.{1,8}/g);
  var partsHex = hexEncryptedText.match(/.{1,2}/g);

  var binaryResultWithSpaces = partsBin.join(" ");
  var hexResultWithSpaces = partsHex.join(" ");

  var resultToDisplay = "bin: " + binaryResultWithSpaces + "\n" + "hex: " + hexResultWithSpaces;

  document.getElementById('outputStream').value = resultToDisplay;

}

//result of whole f function (include expansion, xor, sbox and permuation)
function f_function(rightData, key) {

  var dataAfterExpansion = "";
  for (var i = 0; i < 48; i++) {
      dataAfterExpansion += rightData[EXPANSION[i] - 1];
  };

  var dataAfterXOR = xor(dataAfterExpansion, key);

  var dataAfterSBOX = "";
  for (var i = 0; i < 8; i++) {
      //looking for row
      var currentRowString = dataAfterXOR[i * 6] + dataAfterXOR[i * 6 + 5];
      var currentRowInt = parseInt(currentRowString, 2);

      //looking for col
      var currentColString = dataAfterXOR.substr(i * 6 + 1, 4)
      var currentColInt = parseInt(currentColString, 2);

      //looking for value in S_BOXES table
      var value = S_BOXES[i][currentRowInt][currentColInt];

      //always have 4 bits by padding to start zeros
      var valueBits = value.toString(2).padStart(4, '0');

      dataAfterSBOX += valueBits;
  }

  var dataAfterPermutation = "";
  for (var i = 0; i < 32; i++) {
      dataAfterPermutation += dataAfterSBOX[PERMUTATION[i] - 1];

  }

  return dataAfterPermutation;

}

function xor(a, b) {

  var result = "";
  for (var i = 0; i < b.length; i++) {
      if (a[i] != b[i]) result += "1";
      else result += "0";
  }

  return result;
}