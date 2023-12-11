<!DOCTYPE html>
<html lang='en'>
<meta charset='utf-8'>
<meta content='width=device-width, initial-scale=1.0' name='viewport'>
<title>Hiragana/katakana quiz</title>
<link href='data:,' rel='icon'>
<link rel="stylesheet" type="text/css" href="base.css">
<style>
#quiz {
  text-align: center;
}
.btn {
  display: block;
  max-width: 200px;
  background: #ddd;
  border: solid 2px #ddd;
  margin: 1em auto;
  cursor: pointer;
  border-radius: 0.2em;
  padding: 0.2em;
  user-select: none;
}
.msg {
  font-size: 5em;
}
.blue {
  background: #0095f6!important;
  border: solid 1px #0095f6!important;
  color: #fff;
}
.wrong {
  border: solid 2px #db4e3f!important;
}
.small {
  font-size: 0.8em;
}
</style>

# Hiragana/katakana quiz

Dec 26, 2022

Learn hiragana/katakana by repetition with this endless quiz.

<div id='quiz'>
  <noscript>Sorry, this page requires Javascript to be enabled</noscript>
</div>

<script>
(function() {

'use strict';

const hiragana = [
  ["あ", "a"], ["い", "i"], ["う", "u"], ["え", "e"], ["お", "o"],
  ["か", "ka"], ["き", "ki"], ["く", "ku"], ["け", "ke"], ["こ", "ko"],
  ["さ", "sa"], ["し", "shi"], ["す", "su"], ["せ", "se"], ["そ", "so"],
  ["た", "ta"], ["ち", "chi"], ["つ", "tsu"], ["て", "te"], ["と", "to"],
  ["な", "na"], ["に", "ni"], ["ぬ", "nu"], ["ね", "ne"], ["の", "no"],
  ["は", "ha"], ["ひ", "hi"], ["ふ", "fu"], ["へ", "he"], ["ほ", "ho"],
  ["ま", "ma"], ["み", "mi"], ["む", "mu"], ["め", "me"], ["も", "mo"],
  ["や", "ya"], ["ゆ", "yu"], ["よ", "yo"],
  ["ら", "ra"], ["り", "ri"], ["る", "ru"], ["れ", "re"], ["ろ", "ro"],
  ["わ", "wa"], ["ゐ", "wi"], ["ゑ", "we"], ["を", "wo"],
  ["ん", "n"],
  // diacritics
  ["が", "ga"], ["ぎ", "gi"], ["ぐ", "gu"], ["げ", "ge"], ["ご", "go"],
  ["ざ", "za"], ["じ", "ji"], ["ず", "zu"], ["ぜ", "ze"], ["ぞ", "zo"],
  ["だ", "da"], ["ぢ", "ji"], ["づ", "zu"], ["で", "de"], ["ど", "do"],
  ["ば", "ba"], ["び", "bi"], ["ぶ", "bu"], ["べ", "be"], ["ぼ", "bo"],
  ["ぱ", "pa"], ["ぴ", "pi"], ["ぷ", "pu"], ["ぺ", "pe"], ["ぽ", "po"]
];

const katakana = [
  ['ア', 'a'], ['イ', 'i'], ['ウ', 'u'], ['エ', 'e'], ['オ', 'o'],
  ['カ', 'ka'], ['キ', 'ki'], ['ク', 'ku'], ['ケ', 'ke'], ['コ', 'ko'],
  ['サ', 'sa'], ['シ', 'shi'], ['ス', 'su'], ['セ', 'se'], ['ソ', 'so'],
  ['タ', 'ta'], ['チ', 'chi'], ['ツ', 'tsu'], ['テ', 'te'], ['ト', 'to'],
  ['ナ', 'na'], ['ニ', 'ni'], ['ヌ', 'nu'], ['ネ', 'ne'], ['ノ', 'no'],
  ['ハ', 'ha'], ['ヒ', 'hi'], ['フ', 'fu'], ['ヘ', 'he'], ['ホ', 'ho'],
  ['マ', 'ma'], ['ミ', 'mi'], ['ム', 'mu'], ['メ', 'me'], ['モ', 'mo'],
  ['ヤ', 'ya'], ['ユ', 'yu'], ['ヨ', 'yo'],
  ['ラ', 'ra'], ['リ', 'ri'], ['ル', 'ru'], ['レ', 're'], ['ロ', 'ro'],
  ['ワ', 'wa'], ['ヰ', 'wi'], ['ヱ', 'we'], ['ヲ', 'wo'],
  ['ン', 'n'],
  // diacritics
  ['ガ', 'ga'], ['ギ', 'gi'], ['グ', 'gu'], ['ゲ', 'ge'], ['ゴ', 'go'],
  ['ザ', 'za'], ['ジ', 'ji'], ['ズ', 'zu'], ['ゼ', 'ze'], ['ゾ', 'zo'],
  ['ダ', 'da'], ['ヂ', 'ji'], ['ヅ', 'zu'], ['デ', 'de'], ['ド', 'do'],
  ['バ', 'ba'], ['ビ', 'bi'], ['ブ', 'bu'], ['ベ', 'be'], ['ボ', 'bo'],
  ['パ', 'pa'], ['ピ', 'pi'], ['プ', 'pu'], ['ペ', 'pe'], ['ポ', 'po']
];

//--------------------------------------------------------------------

const state = {
  symbols: [],
  remains: [],
  kana: 0,            // hiragana or katakana
  romaji: 0,          // guessed by kana or romaji
  options: [],
  guess: [],
  correct: 0,
  step: 0,
  slip: false
};

function next(kanaChanged) {
  if (state.remains.length < 1 || kanaChanged) {
    let s = state.kana ? katakana.slice() : hiragana.slice();
    state.symbols = shuffle(s);
    state.remains = state.symbols.slice();
  }
  let selected = state.remains.pop();
  let options = [[selected, true]];
  let acc = [ selected[0] ];
  let len = state.symbols.length;
  for (let i = 0; i < 3; i++) {
    let pair;
    do {
      let r = Math.floor(Math.random() * len);
      pair = state.symbols[r];
    } while(acc.includes(pair[0]));
    options.push([pair, false]);
    acc.push(pair[0]);
  }
  state.options = shuffle(options);
  state.guess = selected;
  state.slip = false;

  if (!kanaChanged) {
    state.step += 1;
  }

  updateUI();
}

function elem(selector, text, clickHandler) {
  let p = selector.split('.');
  let el = document.createElement(p[0]);
  if (p.length > 1) {
    for (let i = 1; i < p.length; i++) {
      el.classList.add(p[i]);
    }
  }
  if (typeof text === 'string') {
    el.innerText = text;
  } else if (typeof text === 'function') {
    el.addEventListener('click', text, false);
  } else if (Array.isArray(text)) {
    for (let i = 0; i < text.length; i++) {
      el.appendChild(text[i]);
    }
  }
  if (typeof clickHandler === 'function') {
    el.addEventListener('click', clickHandler, false);
  }
  return el;
}

function shuffle(array) {
  for (let i = array.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    const temp = array[i];
    array[i] = array[j];
    array[j] = temp;
  }
  return array;
}

function checkAnsw(e) {
  let answ = e.target.innerText;
  let correct = state.guess[Math.abs(state.romaji - 1)] === answ;
  if (correct) {
    if (!state.slip) {
      state.correct += 1;
    }
    next();
  } else {
    e.target.classList.add('wrong');
    state.slip = true;
  }
}

// -------------------------- UI --------------------------------------

const progress = elem('div');
const msg = elem('div.msg');

const btn1 = elem('div.btn', checkAnsw);
const btn2 = elem('div.btn', checkAnsw);
const btn3 = elem('div.btn', checkAnsw);
const btn4 = elem('div.btn', checkAnsw);

const btnToggleKana = elem('div.btn.small', function() {
  state.kana = Math.abs(state.kana - 1);
  next(true);
});

const btnToggleRomaji = elem('div.btn.small', function() {
  state.romaji = Math.abs(state.romaji - 1);
  next(true);
});

const wrapper = elem('div', [
  progress,
  msg,
  btn1,
  btn2,
  btn3,
  btn4,
  elem('div.btn.blue', 'next', function() { next() }),
  elem('hr'),
  elem('h3', 'settings'),
  btnToggleKana,
  btnToggleRomaji
]);

function updateUI() {
  let miss = (state.step - 1) - state.correct;
  progress.innerText = '№ ' + state.step + ' (' + miss + ' missed)';
  msg.innerText = state.guess[state.romaji];

  let options = state.options;
  let btns = [btn1, btn2, btn3, btn4];
  for (let i = 0; i < btns.length; i++) {
    btns[i].classList.remove('wrong');
    btns[i].innerText = options[i][0][Math.abs(state.romaji - 1)];
  }

  // settings

  btnToggleKana.innerText = state.kana ? 'switch to hiragana' : 'switch to katakana';
  btnToggleRomaji.innerText = state.romaji ? 'guess by romaji' : 'guess by kana';
}


// --------------------------- Install and run ------------------------------------

document.getElementById('quiz').appendChild(wrapper);
next();

})();
</script>
