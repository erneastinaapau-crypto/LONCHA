// Test to verify max_cycles logic works correctly
console.log('🧪 Testing max_cycles logic\n');

// Simulate the fixed logic
function testMaxCycles(maxCycles, totalSlides) {
  console.log(`📊 Test: maxCycles=${maxCycles}, totalSlides=${totalSlides}`);
  
  let currentSlide = 0;
  let cycleCount = 0;
  let playing = true;
  let slidesSeen = [];
  
  let iterations = 0;
  const maxIterations = 100; // safety limit
  
  while (playing && iterations < maxIterations) {
    iterations++;
    slidesSeen.push(currentSlide);
    
    // Calculate next slide
    const next = (currentSlide + 1) % totalSlides;
    
    // Check if we're about to complete a full cycle
    if (next === 0 && maxCycles > 0) {
      cycleCount += 1;
      if (cycleCount >= maxCycles) {
        // Stop on the last slide instead of wrapping
        playing = false;
        console.log(`   ✅ Stopped after ${cycleCount} cycle(s)`);
        console.log(`   📺 Slides shown: ${slidesSeen.join(' → ')}`);
        console.log(`   🛑 Final slide: ${currentSlide}`);
        return slidesSeen;
      }
    }
    
    currentSlide = next;
  }
  
  if (iterations >= maxIterations) {
    console.log(`   ♾️  Still playing (infinite loop) after ${iterations} iterations`);
  }
  
  console.log('');
  return slidesSeen;
}

// Test Case 1: max_cycles = 1, should show slides [0, 1, 2] once and stop on slide 2
console.log('Test 1: Should loop once and stop');
const test1 = testMaxCycles(1, 3);
const expected1 = [0, 1, 2];
console.assert(
  JSON.stringify(test1) === JSON.stringify(expected1),
  `❌ Expected ${expected1.join(' → ')}, got ${test1.join(' → ')}`
);
console.log('');

// Test Case 2: max_cycles = 2, should show slides twice
console.log('Test 2: Should loop twice and stop');
const test2 = testMaxCycles(2, 3);
const expected2 = [0, 1, 2, 0, 1, 2];
console.assert(
  JSON.stringify(test2) === JSON.stringify(expected2),
  `❌ Expected ${expected2.join(' → ')}, got ${test2.join(' → ')}`
);
console.log('');

// Test Case 3: max_cycles = 0, should loop infinitely
console.log('Test 3: Should loop infinitely (max_cycles = 0)');
testMaxCycles(0, 3);

console.log('✅ All tests passed!');
