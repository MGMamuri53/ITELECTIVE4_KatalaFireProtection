<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('products', function (Blueprint $table) {
    $table->id();

    $table->string('name');
    $table->string('sku')->unique();
    $table->text('description')->nullable();
    $table->decimal('price', 10, 2);
    $table->string('stock_status')->default('IN STOCK');
    $table->text('image_url')->nullable();
    $table->string('category')->nullable();

    $table->timestamps();
});
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('products');
    }
};
