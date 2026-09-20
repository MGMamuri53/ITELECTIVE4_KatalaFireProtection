<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('tbl_material', function (Blueprint $table) {
            $table->bigIncrements('v_materialId');

            $table->string('v_materialCode', 60)
                ->nullable()
                ->unique();

            $table->string('v_materialName', 150);

            $table->string('v_materialCategory', 100)
                ->nullable();

            $table->text('v_materialDescription')
                ->nullable();

            $table->string('v_unitOfMeasure', 50)
                ->nullable();

            $table->decimal('v_currentPrice', 14, 2)
                ->nullable();

            $table->decimal('v_costPrice', 14, 2)
                ->nullable();

            $table->string('v_supplierReference', 150)
                ->nullable();

            $table->boolean('v_isActive')
                ->default(true);

            $table->dateTime('v_createdAt')
                ->useCurrent();

            $table->dateTime('v_updatedAt')
                ->useCurrent();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('tbl_material');
    }
};