import * as THREE from './vendor/three.module.js';

const $ = id => document.getElementById(id);
const translations = {
  en: {download:'Get the app ↗',tagline:'One bead. One breath. A little more stillness.',settings:'Settings',mantra:'Mantra',goal:'Beads per round',material:'Bead material',voice:'Chant voice',resetQuestion:'Start again?',resetBody:'Reset your count and completed rounds.',cancel:'Cancel',reset:'Reset',share:'Share a quiet moment',native:'Take your practice with you on iPhone & Apple Watch.',store:'Download on the App Store ↗',support:'Support',privacy:'Privacy',terms:'Terms',rounds:'rounds',copied:'Link copied',shareTitle:'MalaWatch — One bead at a time',shareText:'A quiet moment, one bead at a time.',custom:'Custom mantra',soundOn:'Mute voice',soundOff:'Enable voice',count:'Count one bead',speechUnavailable:'Chant voice is not available in this browser.',shareError:'Copy this page’s address to share.'},
  'zh-Hant': {download:'下載 App ↗',tagline:'一顆佛珠，一次呼吸，片刻寧靜。',settings:'設定',mantra:'咒語',goal:'每輪佛珠數',material:'佛珠材質',voice:'跟著念',resetQuestion:'重新開始？',resetBody:'將計數和已完成的圈數歸零。',cancel:'取消',reset:'重設',share:'分享片刻寧靜',native:'在 iPhone 和 Apple Watch 上，隨時開始修持。',store:'前往 App Store 下載 ↗',support:'支援',privacy:'隱私',terms:'條款',rounds:'圈',copied:'已複製連結',shareTitle:'MalaWatch — 一顆佛珠，片刻寧靜',shareText:'送你一個安靜的片刻，一起撥佛珠。',custom:'自訂咒語',soundOn:'關閉聲音',soundOff:'開啟聲音',count:'撥一顆佛珠',speechUnavailable:'此瀏覽器不支援語音。',shareError:'請複製此頁網址分享。'},
  'zh-Hans': {download:'下载 App ↗',tagline:'一颗佛珠，一次呼吸，片刻宁静。',settings:'设置',mantra:'咒语',goal:'每轮佛珠数',material:'佛珠材质',voice:'跟着念',resetQuestion:'重新开始？',resetBody:'将计数和已完成的圈数归零。',cancel:'取消',reset:'重置',share:'分享片刻宁静',native:'在 iPhone 和 Apple Watch 上，随时开始修持。',store:'前往 App Store 下载 ↗',support:'支持',privacy:'隐私',terms:'条款',rounds:'圈',copied:'已复制链接',shareTitle:'MalaWatch — 一颗佛珠，片刻宁静',shareText:'送你一个安静的片刻，一起拨佛珠。',custom:'自定义咒语',soundOn:'关闭声音',soundOff:'开启声音',count:'拨一颗佛珠',speechUnavailable:'此浏览器不支持语音。',shareError:'请复制此页网址分享。'},
  ja: {download:'アプリを入手 ↗',tagline:'一粒、一呼吸。心に静かなひとときを。',settings:'設定',mantra:'真言',goal:'一巡の数珠の数',material:'数珠の素材',voice:'音声ガイド',resetQuestion:'最初から始めますか？',resetBody:'カウントと完了した周回数をリセットします。',cancel:'キャンセル',reset:'リセット',share:'静かなひとときを共有',native:'iPhone と Apple Watch で、いつでも祈りの時間を。',store:'App Store でダウンロード ↗',support:'サポート',privacy:'プライバシー',terms:'利用規約',rounds:'周',copied:'リンクをコピーしました',shareTitle:'MalaWatch — 一粒ずつ、心静かに',shareText:'数珠を一粒ずつ。静かなひとときをどうぞ。',custom:'カスタム真言',soundOn:'音声をオフ',soundOff:'音声をオン',count:'一粒数える',speechUnavailable:'このブラウザでは音声を利用できません。',shareError:'このページの URL をコピーして共有してください。'}
};
const defaults = {count:0,rounds:0,goal:108,chant:0,mantra:'om',custom:'',material:'wood',lang: navigator.language.startsWith('zh') ? (/TW|HK|Hant/i.test(navigator.language)?'zh-Hant':'zh-Hans') : navigator.language.startsWith('ja')?'ja':'en'};
let state = {...defaults};
try {
  const saved = JSON.parse(localStorage.getItem('malawatch-web-v1'));
  if (saved && typeof saved === 'object') {
    for (const key of ['count','rounds','chant']) if (Number.isSafeInteger(saved[key]) && saved[key]>=0) state[key]=saved[key];
    if ([27,54,108].includes(saved.goal)) state.goal=saved.goal;
    if (['om','amitabha','custom'].includes(saved.mantra)) state.mantra=saved.mantra;
    if (['wood','rosewood','jade','obsidian'].includes(saved.material)) state.material=saved.material;
    if (translations[saved.lang]) state.lang=saved.lang;
    if (typeof saved.custom==='string') state.custom=saved.custom.slice(0,160);
    state.count=Math.min(state.count,state.goal);
  }
} catch { /* Storage is optional in private browsing. */ }
let sound=false, renderer, scene, camera, beads=[], visualShift=0, animating=false;
const reducedMotion = matchMedia('(prefers-reduced-motion: reduce)').matches;
const save=()=>{try{localStorage.setItem('malawatch-web-v1',JSON.stringify(state));}catch{}};
const t=key=>translations[state.lang][key]||translations.en[key];
const isChinese=()=>state.lang.startsWith('zh');
function syllables(){
  if(state.mantra==='custom'){
    const text=state.custom.trim();
    return text ? ( /\s/.test(text) ? text.split(/\s+/) : Array.from(text)).slice(0,40) : [t('custom')];
  }
  if(state.mantra==='amitabha') return isChinese()?['南','無','阿','彌','陀','佛'].map(c=>state.lang==='zh-Hans'?({'無':'无','彌':'弥'}[c]||c):c):state.lang==='ja'?['南','無','阿','弥','陀','仏']:['Na','Mo','A','Mi','Tuo','Fo'];
  return isChinese()?['唵','嘛','呢','叭','咪','吽']:state.lang==='ja'?['オン','マ','ニ','ペ','メ','フン']:['Om','Ma','Ni','Pad','Me','Hum'];
}
function update(){
  document.documentElement.lang=state.lang;
  document.querySelectorAll('[data-i18n]').forEach(el=>el.textContent=t(el.dataset.i18n));
  $('language').value=state.lang;
  $('mantra').value=state.mantra;
  $('mantra').options[0].textContent=isChinese()?'唵嘛呢叭咪吽':'Om Mani Padme Hum';
  $('mantra').options[1].textContent=isChinese()?(state.lang==='zh-Hans'?'南无阿弥陀佛':'南無阿彌陀佛'):'Namo Amitabha Buddha';
  $('mantra').options[2].textContent=t('custom');
  $('custom-mantra').hidden=state.mantra!=='custom';
  $('custom-mantra').value=state.custom;
  $('custom-mantra').placeholder=t('custom');
  $('count').textContent=state.count;
  $('goal-label').textContent=state.goal;
  $('rounds').textContent=`${state.rounds} ${state.lang==='en'&&state.rounds===1?'round':t('rounds')}`;
  $('progress-fill').style.width=`${state.count/state.goal*100}%`;
  $('wheel').setAttribute('aria-label',`${t('count')}: ${state.count} / ${state.goal}`);
  $('reset').title=$('reset').ariaLabel=t('reset');
  $('settings').title=$('settings').ariaLabel=t('settings');
  $('sound').title=$('sound').ariaLabel=t(sound?'soundOn':'soundOff');
  $('sound').setAttribute('aria-pressed',String(sound));
  $('voice').checked=sound;
  $('sound').innerHTML=`<i data-lucide="${sound?'volume-2':'volume-x'}"></i>`;
  const parts=syllables(), index=state.chant===0?0:(state.chant-1)%parts.length;
  $('syllable').textContent=parts[index];
  $('syllables').replaceChildren(...parts.map((word,i)=>{const el=document.createElement('span');el.textContent=word;el.className=i===index?'active':'';return el;}));
  $('syllables').classList.toggle('short',parts.length<=6);
  const active=$('syllables').children[index];
  $('syllables').scrollTo({left:active.offsetLeft-$('syllables').offsetLeft-($('syllables').clientWidth-active.clientWidth)/2,behavior:reducedMotion?'instant':'smooth'});
  document.querySelectorAll('[data-goal]').forEach(b=>b.setAttribute('aria-pressed',String(+b.dataset.goal===state.goal)));
  document.querySelectorAll('[data-material]').forEach(b=>b.setAttribute('aria-pressed',String(b.dataset.material===state.material)));
  window.lucide?.createIcons();
  save();
}
function speak(){
  if(!sound || !('speechSynthesis' in window))return;
  const index=(state.chant-1)%syllables().length;
  let text=syllables()[index],lang=isChinese()?(state.lang==='zh-Hans'?'zh-CN':'zh-TW'):state.lang==='ja'?'ja-JP':'en-US';
  if(state.lang==='en' && state.mantra!=='custom') text=(state.mantra==='om'?['Ohm','Mah','Nee','Pahd','May','Hoom']:['Nah','Moh','Ah','Mee','Twoh','Fo'])[index];
  const utterance=new SpeechSynthesisUtterance(text);utterance.lang=lang;utterance.rate=.72;
  speechSynthesis.cancel();speechSynthesis.speak(utterance);
}
function setSound(value){
  sound=value && 'speechSynthesis' in window;
  if(value&&!sound)$('status').textContent=t('speechUnavailable');
  if(!sound && 'speechSynthesis' in window)speechSynthesis.cancel();
  update();
}
const wrapped=n=>((n-1)%state.goal+state.goal)%state.goal+1;
const palettes={wood:['#ce8b43','#9e5728'],rosewood:['#a75b45','#683329'],jade:['#92c5a0','#3a775c'],obsidian:['#6d7078','#292b31']};
function labelTexture(number){
  const c=document.createElement('canvas');c.width=c.height=128;
  const ctx=c.getContext('2d');ctx.fillStyle='#21190f';ctx.globalAlpha=.72;ctx.font='600 48px sans-serif';ctx.textAlign='center';ctx.textBaseline='middle';ctx.fillText(number,64,68);
  const texture=new THREE.CanvasTexture(c);texture.colorSpace=THREE.SRGBColorSpace;return texture;
}
const textures=new Map();
function textureFor(n){if(!textures.has(n))textures.set(n,labelTexture(n));return textures.get(n);}
function woodTexture(){
  const c=document.createElement('canvas');c.width=256;c.height=128;const ctx=c.getContext('2d');ctx.fillStyle='#d8b484';ctx.fillRect(0,0,256,128);
  for(let i=0;i<95;i++){ctx.strokeStyle=`rgba(83,44,20,${.025+(i%5)*.012})`;ctx.lineWidth=.5+i%3;ctx.beginPath();for(let x=0;x<=256;x+=4){const y=i*1.5+Math.sin(x*.027+i*.6)*2.3; x?ctx.lineTo(x,y):ctx.moveTo(x,y);}ctx.stroke();}
  const tex=new THREE.CanvasTexture(c);tex.colorSpace=THREE.SRGBColorSpace;return tex;
}
function initScene(){
  try{
    renderer=new THREE.WebGLRenderer({canvas:$('beads'),alpha:true,antialias:true});
    renderer.setPixelRatio(Math.min(devicePixelRatio,2));renderer.outputColorSpace=THREE.SRGBColorSpace;
    scene=new THREE.Scene();camera=new THREE.OrthographicCamera(-3,3,4,-4,.1,100);camera.position.set(0,0,16);
    scene.add(new THREE.HemisphereLight(0xfff5dc,0x38291e,2.4));
    const key=new THREE.DirectionalLight(0xffeed9,4.5);key.position.set(-4,7,9);scene.add(key);
    const fill=new THREE.DirectionalLight(0xe1edf4,.65);fill.position.set(4,-2,4);scene.add(fill);
    const grain=woodTexture(),sphere=new THREE.SphereGeometry(1,48,32),disc=new THREE.PlaneGeometry(1,1);
    grainMap=grain;
    for(let i=-8;i<=8;i++){
      const material=new THREE.MeshPhysicalMaterial({color:0xb56b32,map:grain,roughness:.29,metalness:0,clearcoat:.65,clearcoatRoughness:.24,transparent:true});
      const mesh=new THREE.Mesh(sphere,material),group=new THREE.Group();group.add(mesh);
      const label=new THREE.Mesh(disc,new THREE.MeshBasicMaterial({transparent:true,depthWrite:false}));label.position.z=1.008;label.scale.set(1.1,1.1,1);group.add(label);
      scene.add(group);beads.push({group,mesh,label,offset:i,number:0});
    }
    const resize=()=>{const {width,height}=$('wheel').getBoundingClientRect();if(!width||!height)return;renderer.setSize(width,height,false);camera.left=-3.5;camera.right=3.5;camera.top=3.5*height/width;camera.bottom=-camera.top;camera.updateProjectionMatrix();render();};
    new ResizeObserver(resize).observe($('wheel'));resize();
  }catch(error){
    $('beads').hidden=true;$('fallback').hidden=false;
    $('fallback').innerHTML='<div class="fallback-bead"></div>';render();
  }
}
function render(){
  if(!renderer||!scene){const bead=$('fallback').firstElementChild;if(bead)bead.textContent=state.count||1;return;}
  const base=state.count||1;
  beads.forEach(({group,mesh,label,offset},i)=>{
    const relative=offset+visualShift, distance=Math.abs(relative),scale=.91*Math.max(.34,1-distance*.12);
    group.position.set(Math.sin(relative*.36)*.65,-relative*.66,2-distance*.47);group.scale.setScalar(scale);
    const n=wrapped(base-offset);
    if(beads[i].number!==n){label.material.map=textureFor(n);label.material.needsUpdate=true;beads[i].number=n;}
    const color=n===1?'#c43d28':palettes[state.material][distance<.6?0:1];mesh.material.color.set(color);
    mesh.material.roughness=state.material==='jade'?.22:.33;
    const map=['jade','obsidian'].includes(state.material)?null:grainMap;
    if(mesh.material.map!==map){mesh.material.map=map;mesh.material.needsUpdate=true;}
    const edgeFade=THREE.MathUtils.clamp((camera.top-Math.abs(group.position.y)-scale*.45)/.65,0,1);
    mesh.material.opacity=edgeFade;
    label.material.opacity=(distance<.7?.85:.18)*edgeFade;
    group.visible=distance<7.8;
  });
  renderer.render(scene,camera);
}
// Retain the generated grain map when changing between stone and wood.
let grainMap;
function settle(from){
  const started=performance.now();animating=true;
  function frame(now){const p=reducedMotion?1:Math.min(1,(now-started)/270);visualShift=from*Math.pow(1-p,3);render();if(p<1)requestAnimationFrame(frame);else{animating=false;visualShift=0;}}
  requestAnimationFrame(frame);
}
function count(shift=0){
  if(animating)return;
  if(state.count>=state.goal){state.count=1;state.rounds++;}else state.count++;
  state.chant++;update();speak();navigator.vibrate?.(8);settle(shift-1);
}
let pointer=null;
$('wheel').addEventListener('pointerdown',e=>{if(animating || (e.pointerType==='mouse'&&e.button!==0))return;pointer={id:e.pointerId,y:e.clientY,x:e.clientX,dy:0};$('wheel').setPointerCapture(e.pointerId);});
$('wheel').addEventListener('pointermove',e=>{if(!pointer||pointer.id!==e.pointerId)return;pointer.dy=e.clientY-pointer.y;visualShift=Math.max(-.35,Math.min(1,pointer.dy/70));render();});
$('wheel').addEventListener('pointerup',e=>{if(!pointer||pointer.id!==e.pointerId)return;const p=pointer;pointer=null;const shift=visualShift;if(p.dy>18 || (Math.abs(p.dy)<8&&Math.abs(e.clientX-p.x)<8))count(shift);else settle(shift);});
$('wheel').addEventListener('pointercancel',()=>{pointer=null;settle(visualShift);});
$('wheel').addEventListener('keydown',e=>{if(['Enter',' ','ArrowDown'].includes(e.key)){e.preventDefault();if(!e.repeat)count();}});
$('settings').onclick=()=>$('settings-dialog').showModal();
$('reset').onclick=()=>$('reset-dialog').showModal();
$('cancel-reset').onclick=()=>$('reset-dialog').close();
$('confirm-reset').onclick=()=>{state.count=0;state.rounds=0;state.chant=0;visualShift=0;if('speechSynthesis'in window)speechSynthesis.cancel();update();render();$('reset-dialog').close();};
$('sound').onclick=()=>setSound(!sound);$('voice').onchange=e=>setSound(e.target.checked);
$('language').onchange=e=>{state.lang=e.target.value;update();};
$('mantra').onchange=e=>{state.mantra=e.target.value;state.chant=0;if('speechSynthesis'in window)speechSynthesis.cancel();update();};
$('custom-mantra').oninput=e=>{state.custom=e.target.value;state.chant=0;update();};
document.querySelectorAll('[data-goal]').forEach(b=>b.onclick=()=>{state.goal=+b.dataset.goal;state.count=0;state.rounds=0;visualShift=0;update();render();});
document.querySelectorAll('[data-material]').forEach(b=>b.onclick=()=>{state.material=b.dataset.material;update();render();});
$('share').onclick=async()=>{
  const url=new URL(location.href);url.search='';url.hash='';
  const data={title:t('shareTitle'),text:t('shareText'),url:url.href};
  try{
    if(navigator.share){
      try{await navigator.share(data);return;}catch(e){if(e.name==='AbortError')return;}
    }
    await navigator.clipboard.writeText(url.href);$('status').textContent=t('copied');
  }catch{$('status').textContent=t('shareError');}
};
document.addEventListener('visibilitychange',()=>{if(document.hidden&&'speechSynthesis'in window)speechSynthesis.cancel();});
update();initScene();grainMap=beads[0]?.mesh.material.map;render();
