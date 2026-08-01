// Quick script to check hero_media max_cycles and duration values
const { createClient } = require('@supabase/supabase-js');
require('dotenv').config();

const supabase = createClient(
  process.env.EXPO_PUBLIC_SUPABASE_URL,
  process.env.EXPO_PUBLIC_SUPABASE_ANON_KEY
);

async function checkHeroCycles() {
  console.log('🔍 Checking hero_media table...\n');
  
  try {
    const { data, error } = await supabase
      .from('hero_media')
      .select('id, position, type, uri, duration, max_cycles, is_active')
      .eq('is_active', true)
      .order('position', { ascending: true });

    if (error) {
      console.error('❌ Error:', error.message);
      return;
    }

    if (!data || data.length === 0) {
      console.log('⚠️  No active hero media found');
      return;
    }

    console.log(`✅ Found ${data.length} active hero media items:\n`);
    
    data.forEach((item, index) => {
      console.log(`📍 Slide ${index + 1} (Position ${item.position}):`);
      console.log(`   Type: ${item.type}`);
      console.log(`   Duration: ${item.duration || 'NOT SET (will default to 5000ms)'}`);
      console.log(`   Max Cycles: ${item.max_cycles !== undefined ? item.max_cycles : 'NOT SET (will default to 0 = infinite)'}`);
      console.log(`   URI: ${item.uri.substring(0, 60)}...`);
      console.log('');
    });

    const firstSlide = data[0];
    const maxCycles = firstSlide.max_cycles || 0;
    
    console.log('📊 Current Behavior:');
    if (maxCycles === 0) {
      console.log('   ♾️  Carousel will loop INFINITELY');
    } else {
      console.log(`   🔄 Carousel will loop ${maxCycles} time(s) then STOP`);
      console.log(`   ⏱️  Total slides: ${data.length}`);
      console.log(`   📺 Total presentations: ${data.length * maxCycles} slides`);
    }
    
  } catch (err) {
    console.error('❌ Exception:', err.message);
  }
}

checkHeroCycles();
