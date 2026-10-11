import * as THREE from "three";
import { AsciiEffect } from "three/examples/jsm/effects/AsciiEffect.js";
import { SVGLoader } from "three/examples/jsm/loaders/SVGLoader.js";
import arcSvg from "@/assets/brand/arc-icon-white.svg?raw";
import usdcSvg from "@/assets/brand/usdc-token.svg?raw";

export const LOGOS = { arc: arcSvg, usdc: usdcSvg };
export type Logo = keyof typeof LOGOS;

const FACE = 0.09;

function emblem(svg: string, material: THREE.Material) {
  const shapes = new SVGLoader()
    .parse(svg)
    .paths.filter((p) => (p.userData?.style as { fill?: string })?.fill === "white")
    .flatMap((p) => SVGLoader.createShapes(p));
  const geo = new THREE.ExtrudeGeometry(shapes, { depth: 8, bevelEnabled: true, bevelThickness: 2, bevelSize: 1.5, bevelSegments: 2, curveSegments: 24 });
  geo.center();
  geo.computeBoundingBox();
  const size = geo.boundingBox!.getSize(new THREE.Vector3());
  const s = 1.15 / Math.max(size.x, size.y);
  const face = (z: number, flip: boolean) => {
    const m = new THREE.Mesh(geo, material);
    m.scale.set(flip ? -s : s, -s, s);
    m.position.z = z;
    return m;
  };
  return { geo, front: face(FACE, false), back: face(-FACE, true) };
}

export function mount(el: HTMLElement, logos: Logo[]) {
  const renderer = new THREE.WebGLRenderer({ antialias: false });
  const effect = new AsciiEffect(renderer, " .:-=+*#%@", { invert: true, resolution: 0.17 });
  el.appendChild(effect.domElement);

  const scene = new THREE.Scene();
  scene.background = new THREE.Color(0);
  const camera = new THREE.PerspectiveCamera(32, 1, 0.1, 20);
  camera.position.z = 4.4;
  scene.add(new THREE.AmbientLight(0xffffff, 0.35));
  const key = new THREE.DirectionalLight(0xffffff, 2.2);
  key.position.set(2, 2.5, 4);
  scene.add(key);
  const rimLight = new THREE.DirectionalLight(0xffffff, 0.8);
  rimLight.position.set(-3, -1, -2);
  scene.add(rimLight);

  const body = new THREE.MeshStandardMaterial({ color: 0x4a4a4a, roughness: 0.55, metalness: 0.3 });
  const raised = new THREE.MeshStandardMaterial({ color: 0xffffff, roughness: 0.3, metalness: 0.1, side: THREE.DoubleSide });
  const disc = new THREE.CylinderGeometry(1, 1, FACE * 2, 96).rotateX(Math.PI / 2);
  const ring = new THREE.TorusGeometry(0.93, 0.045, 16, 96);

  const coin = new THREE.Group();
  coin.add(new THREE.Mesh(disc, body));
  for (const z of [FACE, -FACE]) {
    const r = new THREE.Mesh(ring, raised);
    r.position.z = z;
    coin.add(r);
  }
  const faces = logos.map((l) => {
    const e = emblem(LOGOS[l], raised);
    const g = new THREE.Group().add(e.front, e.back);
    coin.add(g);
    return { g, geo: e.geo };
  });
  scene.add(coin);

  const resize = () => {
    const { width, height } = el.getBoundingClientRect();
    if (!width || !height) return;
    camera.aspect = width / height;
    camera.updateProjectionMatrix();
    renderer.setSize(width, height);
    effect.setSize(width, height);
  };
  const ro = new ResizeObserver(resize);
  ro.observe(el);
  resize();

  const still = matchMedia("(prefers-reduced-motion: reduce)").matches;
  let visible = true;
  let raf = 0;
  let last = 0;
  let t = 0;
  const draw = () => {
    coin.rotation.y = 0.35 + t * 0.75;
    coin.rotation.x = Math.sin(t * 0.6) * 0.22;
    const shown = Math.floor((coin.rotation.y + Math.PI / 2) / Math.PI) % faces.length;
    faces.forEach((f, i) => (f.g.visible = i === shown));
    effect.render(scene, camera);
  };
  const loop = (now: number) => {
    raf = requestAnimationFrame(loop);
    if (!visible || now - last < 33) return;
    t += Math.min(now - last, 100) / 1000;
    last = now;
    draw();
  };
  const io = new IntersectionObserver(([e]) => (visible = e.isIntersecting));
  io.observe(el);
  if (still) draw();
  else raf = requestAnimationFrame(loop);

  return () => {
    cancelAnimationFrame(raf);
    ro.disconnect();
    io.disconnect();
    [disc, ring, ...faces.map((f) => f.geo)].forEach((g) => g.dispose());
    body.dispose();
    raised.dispose();
    renderer.dispose();
    effect.domElement.remove();
  };
}
