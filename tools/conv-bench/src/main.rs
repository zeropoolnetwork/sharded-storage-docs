use p3_goldilocks::Goldilocks;
use p3_field::AbstractField;
use rand::{random};
use rayon::prelude::*;
use std::hint::black_box;

fn main() {

    
    const N:usize = 32;
    const L:usize = 1<<24;
    const K:usize = 4;

    let data: Vec<[Goldilocks; K]> = (0..N).map(|_| random()).collect();
    let data = black_box(data);
    

    let start = std::time::Instant::now();
    
    let res = data.par_iter().map(|t| {
        let mut s = Goldilocks::one();
        for _ in 0..L {
            for j in 0..K {
                s = s*s + t[j];
            }
        }
        s
    }).collect::<Vec<_>>().into_iter().sum::<Goldilocks>();
    
    
    let elapsed = start.elapsed();
    black_box(res);

    let time = elapsed.as_secs() as f64 + f64::from(elapsed.subsec_nanos()) * 1e-9;

    println!("Bitrate for Goldilocks (No RAM): {:.2} GB/s", 2.0 * K as f64 * N as f64 * L as f64 * std::mem::size_of::<Goldilocks>() as f64 / time / 1e9);
    
    



    let data: Vec<(Vec<Goldilocks>,Vec<Goldilocks>)> = (0..N).map(|_| 
        ((0..L).map(|_| random()).collect(),(0..L+K).map(|_| random()).collect())  
    ).collect();


    let start = std::time::Instant::now();
    let data = black_box(data);
    let res = data.par_iter().map(|(a,b)| {
        let mut sum = Goldilocks::default();
        for k in 0..K {
            for i in 0..L {
                sum += a[i] * b[i+k];
            }
        }
        sum
    }).collect::<Vec<Goldilocks>>();
    black_box(res);
    let elapsed = start.elapsed();

    let time = elapsed.as_secs() as f64 + f64::from(elapsed.subsec_nanos()) * 1e-9;

    println!("Bitrate for Goldilocks: {:.2} GB/s", 2.0 * K as f64 * N as f64 * L as f64 * std::mem::size_of::<Goldilocks>() as f64 / time / 1e9);
    

    let data: Vec<(Vec<u64>,Vec<u64>)> = (0..N).map(|_| 
        ((0..L).map(|_| random()).collect(),(0..L+K).map(|_| random()).collect())  
    ).collect();


    let start = std::time::Instant::now();
    let data = black_box(data);
    let res = data.par_iter().map(|(a,b)| {
        let mut sum = u64::default();
        for k in 0..K {
            for i in 0..L {
                sum += a[i] * b[i+k];
            }
        }
        sum
    }).collect::<Vec<u64>>();
    black_box(res);
    let elapsed = start.elapsed();

    let time = elapsed.as_secs() as f64 + f64::from(elapsed.subsec_nanos()) * 1e-9;

    println!("Bitrate for u64: {:.2} GB/s", 2.0 * K as f64 * N as f64 * L as f64 * std::mem::size_of::<Goldilocks>() as f64 / time / 1e9);
    


}
